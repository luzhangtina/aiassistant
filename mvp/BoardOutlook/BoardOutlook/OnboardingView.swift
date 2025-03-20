//
//  OnboardingView.swift
//  BoardOutlook
//
//  Created by lu on 21/3/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var isGetStartedPressed = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                Circle()
                    .fill(Color(hex: 0xf8f4ee, opacity: 0.6))
                    .frame(width: UIScreen.main.bounds.width * 1.01)
                    .position(x: UIScreen.main.bounds.width * 0.39, y: UIScreen.main.bounds.height * 0.1)
                
                Circle()
                    .fill(Color(hex: 0xe9f3fd, opacity: 0.6))
                    .frame(width: UIScreen.main.bounds.width * 1.01)
                    .position(x: UIScreen.main.bounds.width * 0.04, y: UIScreen.main.bounds.height * 0.45)

                Circle()
                    .fill(Color(hex: 0xefeafa, opacity: 0.6))
                    .frame(width: UIScreen.main.bounds.width * 1.01)
                    .position(x: UIScreen.main.bounds.width * 0.96, y: UIScreen.main.bounds.height * 0.24)
                
                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Spacer()
                    
                        HStack {
                            Text("BoardOutlook")
                                .font(.oxanium(size: 22.5))
                                .fontWeight(.semibold)
                            Image(systemName: "sparkles")
                        }
                        .padding(.bottom, 30)
                        
                        Text("Welcome to the\nBoardOutlook\nInterview")
                            .font(.darkerGrotesque(size: 42))
                            .fontWeight(.regular)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: HomeView(), isActive: $isGetStartedPressed) {
                            Button(action: {
                                isGetStartedPressed = true
                            }) {
                                HStack {
                                    Text("Get started").font(.darkerGrotesque(size: 20))
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                
            }
        }
        .navigationBarHidden(true)
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
