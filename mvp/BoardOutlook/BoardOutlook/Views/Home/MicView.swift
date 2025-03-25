//
//  MicView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct MicView: View {
    @Binding var isListening : Bool
    
    var body: some View {
        ZStack {
            if (!isListening) {
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
            } else {
                GlowingBallView()
            }
        }
        .onTapGesture {
            isListening = !isListening
        }
    }
}

#Preview {
    @Previewable @State var isListening = false
    
    MicView(isListening: $isListening)
}

