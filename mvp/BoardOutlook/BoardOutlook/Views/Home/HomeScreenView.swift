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
                    Color(hex: 0x070347),
                    Color(hex: 0x143d92)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Ellipse()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: 0x2a4e9a),
                        Color(hex: 0x2a468f)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom))
                .frame(width: UIScreen.main.bounds.width * 1.3, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height * 0.87)
                
            
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
