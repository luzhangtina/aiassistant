//
//  StaticMicView.swift
//  BoardOutlook
//
//  Created by lu on 26/3/2025.
//

import SwiftUI

struct StaticMicView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.linearGradient(
                    Gradient(
                        colors:
                            [
                                Color(hex: 0x3bb3fd),
                                Color(hex: 0x2e61e6)
                            ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom))
                .frame(width: 68, height: 68)
            
            Image(systemName: "microphone.fill")
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    StaticMicView()
}

