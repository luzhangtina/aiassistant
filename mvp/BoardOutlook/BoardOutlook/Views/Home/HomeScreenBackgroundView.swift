//
//  HomeScreenBackgroundView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct HomeScreenBackgroundView: View {
    @Binding var homeScreenState: HomeScreenViewState
    
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
            
            if (homeScreenState == .surveyIsCompleted) {
                EmptyView()
            }
            else if (homeScreenState == .introduction
                || homeScreenState == .askForGettingReady
                || homeScreenState == .playingQuestion) {
                AudioEclipseView()
            } else {
                LightMovingEclipseView()
            }
        }
    }
}

#Preview {
    @Previewable @State var homeScreenState: HomeScreenViewState = .introduction
    
    HomeScreenBackgroundView(
        homeScreenState: $homeScreenState
    )
}

