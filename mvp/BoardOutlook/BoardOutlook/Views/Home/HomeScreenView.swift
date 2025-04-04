//
//  HomeView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct HomeScreenView : View {
    @State private var homeScreenViewModel = HomeScreenViewModel()

    var body: some View {
        ZStack {
            HomeScreenBackgroundView(homeScreenState: $homeScreenViewModel.currentState)
            
            ZStack {
                CenteredTextView(text: $homeScreenViewModel.currentCenteredText)
                
                VStack {
                    if (homeScreenViewModel.currentState != .loading
                        && homeScreenViewModel.currentState != .surveyIsCompleted) {
                        ToolbarView(
                            selectedMode: $homeScreenViewModel.currentInterviewMode,
                            onClose: {
                                
                            }
                        )
                        
                        if (homeScreenViewModel.currentState == .preparing
                            || homeScreenViewModel.currentState == .microphoneSetUp
                            || homeScreenViewModel.currentState == .obtainMicrophonePermission
                            || homeScreenViewModel.currentState == .introduction
                            || homeScreenViewModel.currentState == .askForGettingReady
                            || homeScreenViewModel.currentState == .userIsReady) {
                            Text("Board Evaluation")
                                .font(.sfProTextRegular(size: 32))
                                .foregroundStyle(.white)
                                .padding(.top, 60)
                            
                            Text("30 mins")
                                .font(.sfProTextRegular(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.top, 20)
                        } else {
                            Spacer()
                        }
                    }
                    
                    switch homeScreenViewModel.currentState {
                    case .loading:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.currentState = .preparing
                                homeScreenViewModel.currentCenteredText = "One moment..."
                            }
                        )
                    case .preparing:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                // Initialize WebSocket connection
                                homeScreenViewModel.establishWebSocketConnection()
                                
                                homeScreenViewModel.currentState = .microphoneSetUp
                                homeScreenViewModel.currentCenteredText = "First, connect your headphones and say something by tapping the mic below for testing..."
                            }
                        )
                    case .microphoneSetUp:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.startRecording()
                                homeScreenViewModel.currentState = .obtainMicrophonePermission
                                homeScreenViewModel.currentCenteredText = "I am listening..."
                            }
                        )
                    case .obtainMicrophonePermission:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.stopRecording()
                                
                                homeScreenViewModel.currentState = .introduction
                                homeScreenViewModel.currentCenteredText = "Great, looks like we are all set. Before we start, let me share a few things about me..."
                            }
                        )
                    case .introduction:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.currentState = .askForGettingReady
                                homeScreenViewModel.currentCenteredText = "Are you ready to get started? Just say 'Yes' or anything like that and I will get right in"
                            }
                        )
                    case .askForGettingReady:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.startRecording()
                                homeScreenViewModel.currentState = .userIsReady
                            }
                        )
                    case .userIsReady:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.stopRecording()
                                
                                // First, change to countdown state
                                homeScreenViewModel.currentState = .countdown
                                homeScreenViewModel.currentCenteredText = ""

                                // Then asynchronously start the interview
                                Task {
                                    await homeScreenViewModel.startInterview()
                                }
                            }
                        )
                    case .countdown:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                // Only proceed to playing question if we have an API response
                                if homeScreenViewModel.interviewProgress != nil {
                                    let currentQuestion = homeScreenViewModel.interviewProgress?.currentQuestion ?? "No current question available"
                                    homeScreenViewModel.currentState = .playingQuestion
                                    homeScreenViewModel.currentCenteredText = currentQuestion
                                } else {
                                    // If API response isn't ready yet, switch to
                                    homeScreenViewModel.currentState = .waitingForResponse
                                    homeScreenViewModel.currentCenteredText = "Loading..."
                                }
                            }
                        )
                    case .playingQuestion:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            audioBase64String: homeScreenViewModel.interviewProgress?.audioBase64,
                            onNext: {
                                let isSurveyCompleted = homeScreenViewModel.interviewProgress?.isSurveyCompleted ?? false
                                if (isSurveyCompleted) {
                                    homeScreenViewModel.currentState = .surveyIsCompleted
                                    homeScreenViewModel.currentCenteredText = "Your responses have been saved"
                                }
                                else {
                                    homeScreenViewModel.currentState = .waitForAnswer
                                }
                            }
                        )
                    case .waitForAnswer:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.startRecording()
                                homeScreenViewModel.currentState = .answering
                            }
                        )
                    case .answering:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.stopRecording()
                                homeScreenViewModel.currentState = .waitingForResponse
                            }
                        )
                    case .waitingForResponse:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                if homeScreenViewModel.interviewProgress != nil {
                                    let currentQuestion = homeScreenViewModel.interviewProgress?.currentQuestion ?? "No current question available"
                                    homeScreenViewModel.currentState = .playingQuestion
                                    homeScreenViewModel.currentCenteredText = currentQuestion
                                }
                            }
                        )
                    case .surveyIsCompleted:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                changeRootViewToInterviewSummaryScreen()
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .onDisappear {
            homeScreenViewModel.closeConnection()
        }
    }
    
    private func changeRootViewToInterviewSummaryScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        // Set the new root view controller to HomeScreenView
        window.rootViewController = UIHostingController(rootView: InterviewSummaryView())
        window.makeKeyAndVisible()
    }
}

#Preview {
    HomeScreenView()
}
