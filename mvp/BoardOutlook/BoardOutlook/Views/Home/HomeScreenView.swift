//
//  HomeView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct HomeScreenView : View {
    @State private var currentState: HomeScreenViewState = .loading
    @State private var currentCenteredText: String = "Let's get started..."
    @State private var currentInterviewMode: InterviewMode = .voice
    @State private var isListening: Bool = false

    var body: some View {
        ZStack {
            HomeScreenBackgroundView(homeScreenState: $currentState)
            
            ZStack {
                CenteredTextView(text: $currentCenteredText)
                
                VStack {
                    if (currentState != .loading) {
                        ToolbarView(
                            selectedMode: $currentInterviewMode,
                            onClose: {
                                
                            }
                        )
                        
                        if (currentState == .preparing
                            || currentState == .microphoneSetUp
                            || currentState == .obtainMicrophonePermission
                            || currentState == .introduction
                            || currentState == .askForGettingReady
                            || currentState == .userIsReady) {
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
                    
                    switch currentState {
                    case .loading:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                currentState = .preparing
                                currentCenteredText = "One moment..."
                            }
                        )
                    case .preparing:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                currentState = .microphoneSetUp
                                currentCenteredText = "First, connect your headphones and say something by tapping the mic below for testing..."
                            }
                        )
                    case .microphoneSetUp:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                // TODO: ask for microphone permission
                                // If permission is granted, then change state
                                // Otherwise, stay on this screen
                                currentState = .obtainMicrophonePermission
                                currentCenteredText = "I am listening..."
                            }
                        )
                    case .obtainMicrophonePermission:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                currentState = .introduction
                                currentCenteredText = "Great, looks like we are all set. Before we start, let me share a few things about me..."
                            }
                        )
                    case .introduction:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                currentState = .askForGettingReady
                                currentCenteredText = "Are you ready to get started? Just say 'Yes' or anything like that and I will get right in"
                            }
                        )
                    case .askForGettingReady:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                currentState = .userIsReady
                            }
                        )
                    case .userIsReady:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                // TODO: Only when user is ready, change to count down
                                // TODO: Otherwise, go back to askForGettingReady
                                currentState = .countdown
                                currentCenteredText = ""
                            }
                        )
                    case .countdown:
                        TransitionView(
                            homeScreenState: $currentState,
                            isListening: $isListening,
                            onNext: {
                                // TODO: Only when user is ready, change to count down
                                // TODO: Otherwise, go back to askForGettingReady
                                currentState = .playingQuestion
                                currentCenteredText = ""
                            }
                        )
                    case .playingQuestion:
                        EmptyView()
                    case .waitForAnswer:
                        EmptyView()
                    case .Answering:
                        EmptyView()
                    case .WaitingForResponse:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    HomeScreenView()
}
