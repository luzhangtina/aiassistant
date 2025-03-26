//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct TransitionView: View {
    @State var countdownNumber: Int = 5
    @Binding var homeScreenState: HomeScreenViewState
    @Binding var isListening: Bool
    
    var onNext: () -> Void
    
    var body: some View {
        ZStack() {
            if (homeScreenState == .countdown) {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        Text(String(countdownNumber))
                            .font(.sfProTextRegular(size: 64))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.3), value: countdownNumber)

                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack() {
                if (homeScreenState == .preparing
                    || homeScreenState == .introduction
                    || homeScreenState == .countdown) {
                    Spacer()
                    
                    if (homeScreenState == .countdown) {
                        Text("Start the interview in...")
                            .font(.sfProTextRegular(size: 16))
                            .foregroundStyle(.white)
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    StaticMicView()
                        .padding(.bottom, 30)
                } else if (homeScreenState == .microphoneSetUp
                            || homeScreenState == .obtainMicrophonePermission
                            || homeScreenState == .askForGettingReady
                            || homeScreenState == .userIsReady) {
                    Spacer()
                    
                    
                    if ((homeScreenState == .askForGettingReady || homeScreenState == .userIsReady)
                        && isListening) {
                        Spacer()
                        
                        Text("I'm listening...")
                            .font(.sfProTextRegular(size: 16))
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    
                    MicView(
                        isListening: $isListening,
                        onTap: onNext
                    )
                    .padding(.bottom, 30)
                }
            }

        }
        .onAppear {
            if (homeScreenState == .countdown) {
                startCountdown()
            } else if (homeScreenState == .loading
                        || homeScreenState == .preparing
                        || homeScreenState == .introduction) {
                DispatchQueue.main.asyncAfter (
                    deadline: .now() + 2.0
                ) {
                    onNext()
                }
            }
        }
    }
    
    func startCountdown() {
        countdownNumber = 5
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.invalidate()
                onNext()
            }
        }
    }
}

#Preview {
    @Previewable @State var homeScreenState: HomeScreenViewState = .countdown
    @Previewable @State var isListening: Bool = false
    
    TransitionView(
        homeScreenState: $homeScreenState,
        isListening: $isListening,
        onNext: {}
    )
}
