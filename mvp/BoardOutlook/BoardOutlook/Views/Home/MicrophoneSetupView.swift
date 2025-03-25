//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct MicrophoneSetupView: View {
    @Binding var selectedMode: InterviewMode
    @Binding var isListening: Bool
    
    var onClose: () -> Void
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 10
        ) {
            ToolbarView(selectedMode: $selectedMode, onClose: onClose)
            .padding(.bottom, 60)
            
            Text("Board Evaluation")
                .font(.sfProTextRegular(size: 32))
                .foregroundStyle(.white)
            
            Text("30 mins")
                .font(.sfProTextRegular(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Spacer()
            
            MicView(isListening: $isListening)
                .padding(.bottom, 30)
        }
    }
}

#Preview {
    @Previewable @State var mode = InterviewMode.voice
    @Previewable @State var isListening = false
    
    return MicrophoneSetupView(
        selectedMode: $mode,
        isListening: $isListening,
        onClose: {})
}
