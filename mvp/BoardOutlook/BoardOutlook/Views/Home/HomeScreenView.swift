//
//  HomeView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct HomeScreenView : View {
    @State private var currentState: HomeScreenViewState = .loading
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0x0c0c4c),
                    Color(hex: 0x0d0d4d)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                switch currentState {
                case .loading:
                    LoadingStateView(onComplete: {
                        withAnimation {
                            currentState = .preparing
                        }
                    })
                case .preparing:
                    PreparingStateView(
                        onComplete: {
                            withAnimation {
                                withAnimation {
                                    currentState = .microphoneSetUp
                                }
                            }
                        },
                        onClose: {
                            
                        }
                    )
                case .microphoneSetUp:
                    MicrophoneSetupView(onComplete: {
                        
                    },
                    onClose: {
                        
                    })
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
