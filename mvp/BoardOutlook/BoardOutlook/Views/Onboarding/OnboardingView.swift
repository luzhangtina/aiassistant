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
            BackgroundCircleView(colorInHex: 0xf8f4ee, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.39, positionYFactor: 0.1)
            BackgroundCircleView(colorInHex: 0xe9f3fd, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.04, positionYFactor: 0.45)
            BackgroundCircleView(colorInHex: 0xefeafa, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.96, positionYFactor: 0.24)
            
            switch currentPage {
                case 0:
                    WelcomePageView(onButtonPress: {
                        withAnimation {
                            currentPage = 1
                        }
                    })
                    
                case 1:
                    BoardEvaluationPageView(
                        onSkip: {
                            withAnimation {
                                currentPage = 99
                            }
                        },
                        onNext: {
                            withAnimation {
                                currentPage = 3
                            }
                        }
                    )
                case 3:
                    HomeView()
                case 4:
                    HomeView()

                default:
                    HomeView()
            }
        }
    }
}

struct HomeView : View {
    var body: some View {
        Text("Home Screen")
            .font(.largeTitle)
            .navigationTitle("Home")
    }
}

#Preview {
    OnboardingView()
}

