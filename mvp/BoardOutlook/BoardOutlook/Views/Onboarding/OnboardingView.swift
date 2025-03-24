//
//  OnboardingView.swift
//  BoardOutlook
//
//  Created by lu on 21/3/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            OnboardingBackgroundView()
            HStack {
                currentPageView()
            }
            .padding(.horizontal, 34)
        }
    }
    
    @ViewBuilder
    private func currentPageView() -> some View {
        switch currentPage {
            case 0:
                WelcomePageView(onButtonPress: goToNextPage)
            case 1:
                BoardEvaluationPageView(
                    onSkip: goHome,
                    onNext: goToNextPage
                )
            case 2:
                InteractiveExperiencePageView(
                    onSkip: goHome,
                    onNext: goToNextPage
                )
            case 3:
                YouAreInControlPageView (
                    onNext: goHome
                )
            default:
                HomeView()
        }
    }
    
    private func goToNextPage() {
        withAnimation { currentPage = currentPage + 1 }
    }
    
    private func goHome() {
        withAnimation { currentPage = 99 }
    }
}

#Preview {
    OnboardingView()
}

