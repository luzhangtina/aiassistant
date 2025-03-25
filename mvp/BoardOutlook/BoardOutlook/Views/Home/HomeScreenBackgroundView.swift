//
//  HomeScreenBackgroundView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct HomeScreenBackgroundView: View {
    @State private var animateGradient = false

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
            
            LightMovingEclipseView()

        }
    }
}

#Preview {
    HomeScreenBackgroundView()
}

