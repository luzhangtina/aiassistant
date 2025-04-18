//
//  ViewModel.swift
//  BoardOutlook
//
//  Created by lu on 29/3/2025.
//

import SwiftUI
import AVFoundation

@Observable
@MainActor
class HomeScreenViewModel {
    var currentState: HomeScreenViewState = .loading
    var currentCenteredText: String = "Let's get started..."
    var currentInterviewMode: InterviewMode = .voice
    var isListening: Bool = false
    var microphoneIsReady: Bool = false
    var interviewMetadata: InterviewMetadata?
    var interviewProgress: InterviewProgress?
    var user: User = User(clientId: "client1", name: "Harshad")
    var laodingInterviewRequest = LoadingInterviewRequest(userId: "user1001", interviewId: "interview_001")
    
    var shouldShowToolbar: Bool {
        switch currentState {
        case .loading, .surveyIsCompleted:
            return false
        default:
            return true
        }
    }
    var shouldShowHeader: Bool {
        switch currentState {
        case .preparing, .tryToObtainMicphonePermission, .testMicrophone, .askForGettingReady, .userIsReady:
            return true
        default:
            return false
        }
    }
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioFormat: AVAudioFormat?
    
    private var sentFirstChunk = false
    
    func establishWebSocketConnection() {
        guard let url = URL(string: "ws://localhost:8001/ws") else { return }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start listening for messages
        receiveMessage()
    }
    
    func closeConnection() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    // Process the message from server
                    DispatchQueue.main.async {
                        self?.handleServerMessage(text)
                    }
                case .data(_):
                    // Handle binary data if needed
                    break
                @unknown default:
                    break
                }
                
                // Continue listening for more messages
                Task { @MainActor in
                    self?.receiveMessage()
                }
                
            case .failure(let error):
                print("WebSocket error: \(error)")
                // Implement reconnection logic if needed
            }
        }
    }
        
    // Handle messages received from the server
    private func handleServerMessage(_ message: String) {
        // Parse the message (adjust based on your server's response format)
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(InterviewProgress.self, from: Data(message.utf8))
            print(response)
            self.interviewProgress = response
            
            // If we're waiting for a response, proceed to playing the question
            if self.currentState == .waitingForResponse {
                let currentQuestion = response.currentQuestion
                self.currentState = .playingQuestion
                self.currentCenteredText = currentQuestion
            }
        } catch {
            print("Failed to decode server message: \(error)")
        }
    }

    func startRecording() {
        isListening = true
        
        let audioSession = AVAudioSession.sharedInstance()
        audioEngine = AVAudioEngine()
        
        sentFirstChunk = false
        
        do {
            // Request permission and set up audio session
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat)  // Changed to .voiceChat mode
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            if #available(iOS 13.0, *) {
                try audioSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
            }
            
            guard let engine = audioEngine else {
                print("Audio engine not initialized")
                return
            }
            
            inputNode = engine.inputNode
            
            // Create the format we want: 16kHz mono PCM
            let targetFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: 16000.0,
                channels: 1,
                interleaved: true
            )
            
            guard let targetFormat = targetFormat else {
                print("Failed to create target format")
                return
            }
            
            // Get native format from input device
            let nativeFormat = inputNode?.outputFormat(forBus: 0)
            
            guard let nativeFormat = nativeFormat else {
                print("Failed to get native format")
                return
            }
            
            print("Native format: \(nativeFormat)")
            print("Target format: \(targetFormat)")
            
            // Enable noise suppression on the input node
            if let inputNode = inputNode, let audioUnit = inputNode.audioUnit {
                var enableFlag: UInt32 = 1
                
                // Define the property IDs for voice processing
                // 1 = kAUVoiceIOProperty_VoiceProcessingEnableAGC (Auto Gain Control)
                // 3 = kAUVoiceIOProperty_VoiceProcessingEnableNS (Noise Suppression)
                let AGCPropertyID: AudioUnitPropertyID = 1
                let NSPropertyID: AudioUnitPropertyID = 3
                
                // Enable automatic gain control (AGC)
                AudioUnitSetProperty(
                    audioUnit,
                    AGCPropertyID,
                    kAudioUnitScope_Global,
                    0,
                    &enableFlag,
                    UInt32(MemoryLayout<UInt32>.size)
                )
                
                // Enable noise suppression (NS)
                AudioUnitSetProperty(
                    audioUnit,
                    NSPropertyID,
                    kAudioUnitScope_Global,
                    0,
                    &enableFlag,
                    UInt32(MemoryLayout<UInt32>.size)
                )
                
                print("Noise suppression enabled")
            }
            
            // Check if conversion is needed
            var needsConversion = true
            if nativeFormat.sampleRate == targetFormat.sampleRate &&
               nativeFormat.channelCount == targetFormat.channelCount &&
               nativeFormat.commonFormat == targetFormat.commonFormat {
                needsConversion = false
                print("No conversion needed")
            }
            
            // Create a converter if needed
            let converter = needsConversion ? AVAudioConverter(from: nativeFormat, to: targetFormat) : nil
                    
            // Install a tap on the input node
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: nativeFormat) { [weak self] buffer, time in
                guard let self = self else { return }
                
                let channelData = buffer.floatChannelData?[0]
                let frameLength = Int(buffer.frameLength)

                if let channelData = channelData {
                    let channelArray = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
                    let sumSquares = channelArray.reduce(0) { $0 + $1 * $1 }
                    let meanSquare = sumSquares / Float(frameLength)
                    let rms = sqrt(meanSquare)
                    let level = 20 * log10(rms)

                    DispatchQueue.main.async {
                        if level > -60 {
                            self.microphoneIsReady = true
                        }
                    }
                }
                
                var pcmData: Data?
                
                if needsConversion, let converter = converter {
                    // Convert to our target format
                    guard let targetBuffer = AVAudioPCMBuffer(
                        pcmFormat: targetFormat,
                        frameCapacity: AVAudioFrameCount(targetFormat.sampleRate / nativeFormat.sampleRate * Double(buffer.frameLength))
                    ) else {
                        print("Failed to create target buffer")
                        return
                    }
                    
                    var error: NSError?
                    
                    let status = converter.convert(to: targetBuffer, error: &error) { inNumPackets, outStatus in
                        outStatus.pointee = .haveData
                        return buffer
                    }
                    
                    if let error = error {
                        print("Conversion error: \(error)")
                        return
                    }
                    
                    if status == .error {
                        print("Conversion failed with status: \(status)")
                        return
                    }
                    
                    // Extract PCM data from the converted buffer
                    pcmData = self.extractPCMData(from: targetBuffer)
                } else {
                    // No conversion needed, use the original buffer
                    pcmData = self.extractPCMData(from: buffer)
                }
                
                // Store the PCM data for testing and verification
                if let data = pcmData {
                    self.sendAudioChunk(data)
                }
            }
            
            // Start the audio engine
            engine.prepare()
            try engine.start()

            print("Recording started successfully")
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    // Extract PCM data from a buffer
    private func extractPCMData(from buffer: AVAudioPCMBuffer) -> Data? {
        // For PCM int16 format
        guard let channelData = buffer.int16ChannelData else {
            return nil
        }
        
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        
        // Create data object to hold the PCM samples
        var data = Data()
        
        // Add samples from each channel
        for channel in 0..<channelCount {
            let samples = channelData[channel]
            data.append(UnsafeBufferPointer(start: samples, count: frameLength))
        }
        
        return data
    }

    // Send audio chunk via WebSocket
    private func sendAudioChunk(_ pcmData: Data) {
        if (currentState == .tryToObtainMicphonePermission || currentState == .testMicrophone) {
            return;
        }
        
        var dataToSend = Data()
        var isFirstChunk = false
        if !sentFirstChunk {
            print("Sending first PCM chunk")
            sentFirstChunk = true
            isFirstChunk = true
        }
        
        // Add the PCM data
        dataToSend.append(pcmData)
        
        // Base64 encode
        let base64String = dataToSend.base64EncodedString()
        
        // Determine message type based on current state
        let type = currentStateToType()
        
        // Create message
        let userAnswer = UserAnswer(
            clientId: user.clientId,
            name: user.name,
            type: type,
            audioBase64: base64String,
            isFirstChunk: isFirstChunk,
            isLastChunk: false
        )
        
        // Send via WebSocket
        do {
            let jsonData = try JSONEncoder().encode(userAnswer)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        print("Failed to send audio chunk: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }

    // Stop recording and send final message
    func stopRecording() {
        guard let engine = audioEngine else { return }
        
        // Remove the tap
        inputNode?.removeTap(onBus: 0)
        
        // Stop the engine
        engine.stop()
        
        print("Recording stopped.")
        
        // Send final message
        flushRemainingAudio()
        
        isListening = false
    }

    // Send final message
    private func flushRemainingAudio() {
        if (currentState == .tryToObtainMicphonePermission || currentState == .testMicrophone) {
            return;
        }
        
        print("Sending final message...")
        
        let type = currentStateToType()
        
        let userAnswer = UserAnswer(
            clientId: user.clientId,
            name: user.name,
            type: type,
            audioBase64: nil,
            isFirstChunk: false,
            isLastChunk: true
        )
        
        do {
            let jsonData = try JSONEncoder().encode(userAnswer)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        print("Failed to send final message: \(error)")
                    } else {
                        print("Final message sent successfully")
                    }
                }
            }
        } catch {
            print("Failed to encode final message: \(error)")
        }
    }

    // Determine message type based on current state
    private func currentStateToType() -> String {
        if (currentState == .askForGettingReady || currentState == .userIsReady) {
            return "IsUserReady"
        }
        return "InterviewAnswer"
    }
    
    func startInterview() async {
        guard let url = URL(string: "http://localhost:8001/api/init") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)
        
        let session = URLSession(configuration: .default)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid server response")
                return
            }
            
            let interviewProgress = try JSONDecoder().decode(InterviewProgress.self, from: data)
            print(interviewProgress)
            self.interviewProgress = interviewProgress
            if self.currentState == .waitingForResponse {
                    let currentQuestion = self.interviewProgress?.currentQuestion ?? "No current question available"
                    self.currentState = .playingQuestion
                    self.currentCenteredText = currentQuestion
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            self.currentState = .askForGettingReady
            self.currentCenteredText = "Something went wrong. Let's try again."
        }
    }
    
    func loadingInterview() async {
        guard let url = URL(string: "http://localhost:8001/api/loadingInterview") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(laodingInterviewRequest)

        let session = URLSession(configuration: .default)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid server response")
                return
            }
            
            let interviewMetadata = try JSONDecoder().decode(InterviewMetadata.self, from: data)

            self.interviewMetadata = interviewMetadata
            self.currentState = .preparing
            self.currentCenteredText = "One moment..."
        } catch {
            print("Error: \(error.localizedDescription)")
            self.currentCenteredText = "Something went wrong. Let's try again."
        }
    }
    
    func prepareWebSocketConnection() {
        establishWebSocketConnection()
        self.currentState = .tryToObtainMicphonePermission
        self.currentCenteredText = "First, connect your headphones and say something by tapping the mic below for testing..."
    }
    
    func retryTestingMicrophone() {
        print("retryTestingMicrophone")
        self.currentState = .tryToObtainMicphonePermission
        self.currentCenteredText = "Please enable microphone access in Settings and say something by tapping the mic below for testing..."
    }
    
    func startTestingMicrophone() {
        let permissionStatus = AVAudioApplication.shared.recordPermission

        switch permissionStatus {
        case .granted:
            startRecordingToTestMicrophone()
        case .denied:
            retryTestingMicrophone()
        case .undetermined:
            print("undetermined")
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.startRecordingToTestMicrophone()
                    } else {
                        self.retryTestingMicrophone()
                    }
                }
            }
        @unknown default:
            retryTestingMicrophone()
        }
    }
    
    func startRecordingToTestMicrophone() {
        startRecording()
        self.currentState = .testMicrophone
        self.currentCenteredText = "Please tap the mic below to stop testing."
    }
    
    func stopTestingMicrophone() {
        stopRecording()
        if (microphoneIsReady) {
            self.currentState = .askForGettingReady
            self.currentCenteredText = "Great, looks like we are all set. Are you ready to get started? Just say 'Yes' and I will get right in"
        } else {
            self.currentState = .tryToObtainMicphonePermission
            self.currentCenteredText = "Microphone is not working, please check your microphone and say something by tapping the mic below for testing again..."
        }
    }
    
    func advanceToUserIsReady() {
        currentState = .userIsReady
    }
    
    @MainActor
    func advanceFromUserReady() async {
        stopRecording()
        
        currentState = .countdown
        currentCenteredText = ""
        
        await startInterview()
    }
    
    @MainActor
    func advanceFromCountdown() {
        if let currentQuestion = interviewProgress?.currentQuestion {
            currentState = .playingQuestion
            currentCenteredText = currentQuestion
        } else {
            currentState = .waitingForResponse
            currentCenteredText = "Loading..."
        }
    }
    
    @MainActor
    func advanceFromPlayingQuestion() {
        if interviewProgress?.isSurveyCompleted == true {
            currentState = .surveyIsCompleted
            currentCenteredText = "Your responses have been saved"
        } else {
            currentState = .waitForAnswer
        }
    }
    
    @MainActor
    func beginAnswering() {
        startRecording()
        currentState = .answering
    }
    
    @MainActor
    func finishAnswering() {
        stopRecording()
        currentState = .waitingForResponse
    }
    
    @MainActor
    func advanceFromWaitingForResponse() {
        guard let progress = interviewProgress else { return }

        currentState = .playingQuestion
        currentCenteredText = progress.currentQuestion
    }
    
    @MainActor
    func moveToInterviewSummaryScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        window.rootViewController = UIHostingController(rootView: InterviewSummaryView())
        window.makeKeyAndVisible()
    }
}


// Helper extension to convert integers to Data
extension FixedWidthInteger {
    var data: Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
