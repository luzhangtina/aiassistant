//
//  MicView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct MicView: View {
    @Binding var isListening : Bool
    
    var onTap: () -> Void
    
    var body: some View {
        ZStack {
            if (!isListening) {
                StaticMicView()
            } else {
                GlowingBallView()
            }
        }
        .onTapGesture {
            isListening = !isListening
            onTap()
        }
    }
}

#Preview {
    @Previewable @State var isListening = false
    
    MicView(
        isListening: $isListening,
        onTap: {}
    )
}

