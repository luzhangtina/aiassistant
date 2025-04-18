//
//  NoMicphoneInteractionView.swift
//  BoardOutlook
//
//  Created by lu on 14/4/2025.
//

import SwiftUI

struct NoMicphoneInteractionView: View {
    @Binding var homeScreenState: HomeScreenViewState

    var body: some View {
        Spacer()
        if homeScreenState == .countdown {
            Text("Start the interview in...")
                .font(.sfProTextRegular(size: 16))
                .foregroundStyle(.white)
            Spacer()
            Spacer()
            Spacer()
        }
        StaticMicView().padding(.bottom, 30)
    }
}

#Preview {
    @Previewable @State var homeScreenState: HomeScreenViewState = .countdown
    NoMicphoneInteractionView(homeScreenState: $homeScreenState)
}
