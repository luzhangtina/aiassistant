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
                    if (homeScreenViewModel.currentState != .loading) {
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
                                homeScreenViewModel.currentState = .microphoneSetUp
                                homeScreenViewModel.currentCenteredText = "First, connect your headphones and say something by tapping the mic below for testing..."
                            }
                        )
                    case .microphoneSetUp:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                // TODO: ask for microphone permission
                                // If permission is granted, then change state
                                // Otherwise, stay on this screen
                                homeScreenViewModel.currentState = .obtainMicrophonePermission
                                homeScreenViewModel.currentCenteredText = "I am listening..."
                            }
                        )
                    case .obtainMicrophonePermission:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
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
                                homeScreenViewModel.currentState = .userIsReady
                            }
                        )
                    case .userIsReady:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                Task {
                                    let user = User(clientId: "client1", name: "Harshad")
                                    await homeScreenViewModel.startInterview(for: user)
                                }
                            }
                        )
                    case .countdown:
                        TransitionView(
                            homeScreenState: $homeScreenViewModel.currentState,
                            isListening: $homeScreenViewModel.isListening,
                            onNext: {
                                homeScreenViewModel.currentState = .playingQuestion
                                homeScreenViewModel.currentCenteredText = ""
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
