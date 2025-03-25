//
//  VoiceTextToggleView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct VoiceTextToggleView: View {
    @Binding var selectedMode: InterviewMode

    var body: some View {
        ZStack {
            Capsule()
                .fill(.white.opacity(0.15))
            
            HStack {
                Capsule()
                    .fill(Color.white)
                    .frame(width: UIScreen.main.bounds.width * 0.16, height: UIScreen.main.bounds.height * 0.037)
                    .offset(x: selectedMode == .voice ? UIScreen.main.bounds.width * (-0.08) : UIScreen.main.bounds.width * 0.08)
            }

            HStack {
                Text("Voice")
                    .foregroundStyle(selectedMode == .voice ? .black : .white)
                    .font(.sfProTextRegular(size: 13))
                    .fontWeight(.medium)
                Spacer()
                Text("Text")
                    .foregroundStyle(selectedMode == .voice ? .white : .black)
                    .font(.sfProTextRegular(size: 13))
                    .fontWeight(.medium)
            }
            .padding(.horizontal, UIScreen.main.bounds.width * 0.04)
        }
        .frame(width: UIScreen.main.bounds.width * 0.32, height: UIScreen.main.bounds.height * 0.037 )
        .onTapGesture {
            withAnimation {
                selectedMode = selectedMode == .voice ? .text : .voice
            }
        }
    }
}

#Preview {
    @Previewable @State var mode = InterviewMode.voice
    return VoiceTextToggleView(selectedMode: $mode)
}
