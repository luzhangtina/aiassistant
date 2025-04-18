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
                            InterviewHeader(
                                title: .constant(homeScreenViewModel.interviewMetadata?.title ?? ""),
                                estimatedDuration: .constant(homeScreenViewModel.interviewMetadata?.estimatedDuration ?? 0),
                                durationUnit: .constant(homeScreenViewModel.interviewMetadata?.durationUnit ?? "minute")
                            )
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
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {}
            )
        case .preparing:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {}
            )
        case .tryToObtainMicphonePermission:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {}
            )
        case .testMicrophone:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {}
            )
        case .introduction:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {}
            )
        case .askForGettingReady:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {
                    homeScreenViewModel.startRecording()
                    homeScreenViewModel.advanceToUserIsReady()
                }
            )
        case .userIsReady:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: {
                    Task {
                        await homeScreenViewModel.advanceFromUserReady()
                    }
                }
            )
        case .countdown:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: homeScreenViewModel.advanceFromCountdown
            )
        case .playingQuestion:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                audioBase64String: homeScreenViewModel.interviewProgress?.audioBase64,
                onNext: homeScreenViewModel.advanceFromPlayingQuestion
            )
        case .waitForAnswer:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: homeScreenViewModel.beginAnswering
            )
        case .answering:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: homeScreenViewModel.finishAnswering
            )
        case .waitingForResponse:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: homeScreenViewModel.advanceFromWaitingForResponse
            )
        case .surveyIsCompleted:
            TransitionView(
                homeScreenViewModel: $homeScreenViewModel,
                onNext: homeScreenViewModel.moveToInterviewSummaryScreen
            )
        }
    }
}

#Preview {
    HomeScreenView()
}
