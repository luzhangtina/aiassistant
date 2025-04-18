//
//  MicrophoneInteractionView.swift
//  BoardOutlook
//
//  Created by lu on 14/4/2025.
//

import SwiftUI


struct MicrophoneInteractionView: View {
    @Binding var homeScreenState: HomeScreenViewState
    @Binding var isListening: Bool
    var onNext: () -> Void

    var body: some View {
        Spacer()
        if (homeScreenState == .waitingForUserToConfirmReady ||
            homeScreenState == .answering) && isListening {
            Spacer()
            Spacer()
            Text("I'm listening...")
                .font(.sfProTextRegular(size: 16))
                .foregroundStyle(.white)
            Spacer()
        }
        
        ZStack {
            if (!isListening) {
                StaticMicView()
            } else {
                GlowingBallView()
            }
        }
        .onTapGesture {
            onNext()
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    @Previewable @State var homeScreenState: HomeScreenViewState = .answering
    @Previewable @State var isListening: Bool = true
    
    MicrophoneInteractionView(homeScreenState: $homeScreenState, isListening: $isListening, onNext: {})
}
