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
            VStack(alignment: .leading, spacing: 10) {
                    currentPageView()
                    bottomButton()
                }
                .padding(.horizontal, 32)
        }
    }
    
    @ViewBuilder
    private func currentPageView() -> some View {
        Group {
            switch currentPage {
                case 0:
                    WelcomePageView()
                case 1:
                    BoardEvaluationPageView(onSkip: goHome)
                case 2:
                    InteractiveExperiencePageView(onSkip: goHome)
                case 3:
                    YouAreInControlPageView (onNext: goHome)
                default:
                    HomeView()
            }
        }
        .transition(.moveUpAndFade)
    }
    
    @ViewBuilder
    private func bottomButton() -> some View {
        switch currentPage {
            case 0:
                Button(action: goToNextPage) {
                    HStack {
                        Text("Get started")
                            .font(.darkerGrotesque(size: 20))
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .foregroundColor(.onboardingButtonForeground)
                    .background(.onboardingButtonBackground)
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity, maxHeight: 48)
                .contentShape(Rectangle())
            case 1:
                NextButtonView(onNext: goToNextPage)
            case 2:
                NextButtonView(onNext: goToNextPage)
            case 3:
                NextButtonView(onNext: goToNextPage)
            default:
                EmptyView()
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

