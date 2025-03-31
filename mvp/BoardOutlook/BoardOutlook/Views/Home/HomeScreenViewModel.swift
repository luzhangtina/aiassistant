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
    var interviewProgress: InterviewProgress?
    var user: User = User(clientId: "client1", name: "Harshad")
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioFormat: AVAudioFormat?
    
    private var sentFirstChunk = false
    private var totalBytesSent = 0
    private var audioChunks = [Data]()
    
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
    
    // Start recording audio
//    func startRecording() {
//        let audioSession = AVAudioSession.sharedInstance()
//        
//        do {
//            try audioSession.setCategory(.record, mode: .default)
//            try audioSession.setActive(true)
//            
//            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            recordingURL = documentsPath.appendingPathComponent("recording.wav")
//            
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatLinearPCM),
//                AVSampleRateKey: 16000.0,  // Sample rate for speech
//                AVNumberOfChannelsKey: 1,   // Mono channel
//                AVLinearPCMBitDepthKey: 16, // 16-bit depth
//                AVLinearPCMIsBigEndianKey: false,
//                AVLinearPCMIsFloatKey: false
//            ] as [String : Any]
//            
//            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
//            audioRecorder?.record()
//
//        } catch {
//            print("Failed to start recording: \(error)")
//        }
//    }
    
    // Stop recording and return the audio data
//    func stopRecording() -> Data? {
//        audioRecorder?.stop()
//        isListening = false
//        
//        guard let recordingURL = recordingURL else { return nil }
//        
//        do {
//            let audioData = try Data(contentsOf: recordingURL)
//            return audioData
//        } catch {
//            print("Failed to load audio data: \(error)")
//            return nil
//        }
//    }
    // Properly create a WAV header with accurate values
    private func createWavHeader(sampleRate: Int, bitsPerSample: Int, channels: Int, dataSize: Int) -> Data {
        var header = Data(capacity: 44)
        
        // "RIFF" chunk descriptor
        header.append(contentsOf: "RIFF".utf8)
        
        // Chunk size (file size - 8 bytes)
        let fileSize = dataSize + 36
        let fileSizeData = withUnsafeBytes(of: UInt32(fileSize).littleEndian) { Data($0) }
        header.append(fileSizeData)
        
        // Format ("WAVE")
        header.append(contentsOf: "WAVE".utf8)
        
        // "fmt " sub-chunk
        header.append(contentsOf: "fmt ".utf8)
        
        // Sub-chunk size (16 for PCM)
        let subchunk1SizeData = withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }
        header.append(subchunk1SizeData)
        
        // Audio format (1 for PCM)
        let audioFormatData = withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }
        header.append(audioFormatData)
        
        // Number of channels
        let channelsData = withUnsafeBytes(of: UInt16(channels).littleEndian) { Data($0) }
        header.append(channelsData)
        
        // Sample rate
        let sampleRateData = withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) }
        header.append(sampleRateData)
        
        // Byte rate (SampleRate * NumChannels * BitsPerSample/8)
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let byteRateData = withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Data($0) }
        header.append(byteRateData)
        
        // Block align (NumChannels * BitsPerSample/8)
        let blockAlign = channels * bitsPerSample / 8
        let blockAlignData = withUnsafeBytes(of: UInt16(blockAlign).littleEndian) { Data($0) }
        header.append(blockAlignData)
        
        // Bits per sample
        let bitsPerSampleData = withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Data($0) }
        header.append(bitsPerSampleData)
        
        // "data" sub-chunk
        header.append(contentsOf: "data".utf8)
        
        // Sub-chunk size (data size)
        let subchunk2SizeData = withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) }
        header.append(subchunk2SizeData)
        
        return header
    }

    // Create a test file to verify our recording setup works
    private func createTestWavFile() {
        // Collect all audio data from chunks
        var allAudioData = Data()
        
        // If we have accumulated chunks, use them
        if !audioChunks.isEmpty {
            for chunk in audioChunks {
                allAudioData.append(chunk)
            }
        } else {
            // Generate a simple tone if no data (for testing)
            let sampleRate = 16000
            let duration = 2.0 // 2 seconds
            let sampleCount = Int(duration * Double(sampleRate))
            
            for i in 0..<sampleCount {
                // Generate a 440Hz sine wave
                let time = Double(i) / Double(sampleRate)
                let amplitude = 0.5 * sin(2.0 * .pi * 440.0 * time)
                
                // Convert to 16-bit PCM
                let sample = Int16(amplitude * 32767.0)
                let sampleData = withUnsafeBytes(of: sample.littleEndian) { Data($0) }
                allAudioData.append(sampleData)
            }
        }
        
        // Create a proper WAV header for the complete file
        let header = createWavHeader(
            sampleRate: 16000,
            bitsPerSample: 16,
            channels: 1,
            dataSize: allAudioData.count
        )
        
        // Combine header with audio data
        var wavData = header
        wavData.append(allAudioData)
        
        // Save to a file in the Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("test_recording.wav")
        
        do {
            try wavData.write(to: filePath)
            print("Test WAV file saved to: \(filePath)")
        } catch {
            print("Failed to save test WAV file: \(error)")
        }
    }

    // Modified startRecording function with verified audio capture
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        audioEngine = AVAudioEngine()
        
        // Clear previous data
        audioChunks.removeAll()
        sentFirstChunk = false
        totalBytesSent = 0
        
        do {
            // Request permission and set up audio session
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
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
                    self.audioChunks.append(data)
                    self.totalBytesSent += data.count
                    
                    // Send via WebSocket
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
        
        // Debug - log some characteristics
        if frameLength > 0 {
            let first = channelData[0][0]
            let last = channelData[0][frameLength-1]
            print("Frame count: \(frameLength), First: \(first), Last: \(last), Size: \(data.count) bytes")
        }
        
        return data
    }

    // Send audio chunk via WebSocket
    private func sendAudioChunk(_ pcmData: Data) {
        // If this is the first chunk, we need to create and send a WAV header
        var dataToSend = Data()
        
        if !sentFirstChunk {
            print("Sending first chunk with WAV header")
            
            // We don't know the final size, so use a placeholder
            // Clients will typically update this with the correct size when writing the file
            let header = createWavHeader(
                sampleRate: 16000,
                bitsPerSample: 16,
                channels: 1,
                dataSize: 10 * 1024 * 1024  // 10MB placeholder
            )
            
            dataToSend.append(header)
            sentFirstChunk = true
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
            isFirstChunk: !sentFirstChunk, // Will be true for the first chunk
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
        
        print("Recording stopped. Total bytes recorded: \(totalBytesSent)")
        
        // Create a test WAV file to verify the recording worked
        createTestWavFile()
        
        // Send final message
        flushRemainingAudio()
    }

    // Send final message
    private func flushRemainingAudio() {
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
                webSocketTask?.send(.string(jsonString)) { [weak self] error in
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
        if (currentState == .microphoneSetUp || currentState == .obtainMicrophonePermission) {
            return "MicrophoneTest"
        } else if (currentState == .askForGettingReady || currentState == .userIsReady) {
            return "IsUserReady"
        }
        return "InterviewAnswer"
    }
    
    func startInterview(for user: User) async {
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
}


// Helper extension to convert integers to Data
extension FixedWidthInteger {
    var data: Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
