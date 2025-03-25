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
    
    var body: some View {
        ZStack {
            HomeScreenBackgroundView()
            
            CenteredTextView(text: $currentCenteredText)
            
            VStack {
                Spacer()
                
                switch currentState {
                case .loading:
                    LoadingStateView(onComplete: {
                        currentState = .preparing
                        currentCenteredText = "One moment..."
                    })
                case .preparing:
                    PrepareView(
                        selectedMode: $currentInterviewMode,
                        onComplete: {
                            currentState = .microphoneSetUp
                            currentCenteredText = "First, connect your headphones and say something by tapping the mic below for testing..."
                        },
                        onClose: {
                            
                        }
                    )
                case .microphoneSetUp:
                    PrepareView(
                        selectedMode: $currentInterviewMode,
                        onComplete: {
                        },
                        onClose: {
                            
                        }
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    HomeScreenView()
}
