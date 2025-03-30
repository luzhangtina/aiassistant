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
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            recordingURL = documentsPath.appendingPathComponent("recording.wav")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 16000.0,  // Sample rate for speech
                AVNumberOfChannelsKey: 1,   // Mono channel
                AVLinearPCMBitDepthKey: 16, // 16-bit depth
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ] as [String : Any]
            
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.record()

        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    // Stop recording and return the audio data
    func stopRecording() -> Data? {
        audioRecorder?.stop()
        isListening = false
        
        guard let recordingURL = recordingURL else { return nil }
        
        do {
            let audioData = try Data(contentsOf: recordingURL)
            return audioData
        } catch {
            print("Failed to load audio data: \(error)")
            return nil
        }
    }
        
    // Send audio data via WebSocket
    func sendAudioViaWebSocket(_ audioData: Data?) {
        guard let audioData = audioData else { return }
        
        // Convert audio data to base64 string
        let base64String = audioData.base64EncodedString()
        
        let userAnswer = UserAnswer(
            clientId: user.clientId,
            name: user.name,
            audioBase64: base64String)
        
        do {
            let jsonData = try JSONEncoder().encode(userAnswer)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        print("Failed to send audio via WebSocket: \(error)")
                    }
                }
            } else {
                print("Failed to convert jsonData to string.")
            }
        } catch {
            print("Failed to encode userAnswer to JSON: \(error)")
        }
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

