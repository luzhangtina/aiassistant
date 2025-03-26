//
//  ContentView.swift
//  BoardOutlook
//
//  Created by lu on 26/3/2025.
//

import SwiftUI

struct GlowingBallView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(hex: 0x3bb3fd),
                                Color(hex: 0x2e61e6)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            GifView(gifName: "GlowingBall")
                .clipShape(Circle())
                .blendMode(.screen)
        }
        .frame(width: 68, height: 68)
    }
}

#Preview {
    GlowingBallView()
}
