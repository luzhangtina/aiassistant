//
//  MicrophoneInteractionView.swift
//  BoardOutlook
//
//  Created by lu on 14/4/2025.
//

import SwiftUI


struct MicrophoneInteractionView: View {
    var homeScreenState: HomeScreenViewState
    var isListening: Bool
    var onNext: () -> Void

    var body: some View {
        Spacer()
        if (homeScreenState == .askForGettingReady ||
            homeScreenState == .userIsReady ||
            homeScreenState == .answering) && isListening {
            Spacer()
            Spacer()
            Text("I'm listening...")
                .font(.sfProTextRegular(size: 16))
                .foregroundStyle(.white)
            Spacer()
        }

        MicView(
            isListening: .constant(isListening),
            onTap: onNext
        )
        .padding(.bottom, 30)
    }
}

#Preview {
    MicrophoneInteractionView(homeScreenState: .answering, isListening: true, onNext: {})
}
