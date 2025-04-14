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
                    if (homeScreenViewModel.shouldShowToolbar) {
                        ToolbarView(
                            selectedMode: $homeScreenViewModel.currentInterviewMode,
                            onClose: {}
                        )
                        
                        if (homeScreenViewModel.shouldShowHeader) {
                            InterviewHeader()
                        } else {
                            Spacer()
                        }
                    }
                    
                    transitionForCurrentState()
                }
            }
            .padding(.horizontal, 32)
        }
        .onDisappear {
            homeScreenViewModel.closeConnection()
        }
    }
    
    @ViewBuilder
    func transitionForCurrentState() -> some View {
        switch homeScreenViewModel.currentState {
        case .loading:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.advanceToPreparing
            )
        case .preparing:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: {
                    // Initialize WebSocket connection
                    homeScreenViewModel.establishWebSocketConnection()
                    homeScreenViewModel.advanceToMicrophoneSetUp()
                }
            )
        case .microphoneSetUp:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: {
                    homeScreenViewModel.startRecording()
                    homeScreenViewModel.advanceToObtainMicrophonePermission()
                }
            )
        case .obtainMicrophonePermission:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: {
                    homeScreenViewModel.stopRecording()
                    homeScreenViewModel.advanceToIntroduction()
                }
            )
        case .introduction:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.advanceToAskForGettingReady
            )
        case .askForGettingReady:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: {
                    homeScreenViewModel.startRecording()
                    homeScreenViewModel.advanceToUserIsReady()
                }
            )
        case .userIsReady:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: {
                    Task {
                        await homeScreenViewModel.advanceFromUserReady()
                    }
                }
            )
        case .countdown:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.advanceFromCountdown
            )
        case .playingQuestion:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                audioBase64String: homeScreenViewModel.interviewProgress?.audioBase64,
                onNext: homeScreenViewModel.advanceFromPlayingQuestion
            )
        case .waitForAnswer:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.beginAnswering
            )
        case .answering:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.finishAnswering
            )
        case .waitingForResponse:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.advanceFromWaitingForResponse
            )
        case .surveyIsCompleted:
            TransitionView(
                homeScreenState: $homeScreenViewModel.currentState,
                isListening: $homeScreenViewModel.isListening,
                onNext: homeScreenViewModel.moveToInterviewSummaryScreen
            )
        }
    }
}

#Preview {
    HomeScreenView()
}
