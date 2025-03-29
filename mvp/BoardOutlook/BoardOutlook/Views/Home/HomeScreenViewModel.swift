//
//  ViewModel.swift
//  BoardOutlook
//
//  Created by lu on 29/3/2025.
//

import SwiftUI

@Observable
class HomeScreenViewModel {
    var currentState: HomeScreenViewState = .loading
    var currentCenteredText: String = "Let's get started..."
    var currentInterviewMode: InterviewMode = .voice
    var isListening: Bool = false
    var interviewProgress: InterviewProgress?
    
    func startInterview(for user: User) async {
        guard let url = URL(string: "http://localhost:7001/api/init") else { return }
        
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
            self.currentState = .countdown
            self.currentCenteredText = ""
        } catch {
            print("Error: \(error.localizedDescription)")
            self.currentState = .askForGettingReady
            self.currentCenteredText = "Something went wrong. Let's try again."
        }
    }
}

