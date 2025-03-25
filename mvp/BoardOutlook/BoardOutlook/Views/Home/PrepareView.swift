//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct PrepareView: View {
    @Binding var selectedMode: InterviewMode
    
    var onComplete: () -> Void
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
            
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 68, height: 68)
                
                Image(systemName: "microphone.fill")
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 2.0
            ) {
                onComplete()
            }
        }
    }
}

#Preview {
    @Previewable @State var mode = InterviewMode.voice
    
    return PrepareView(selectedMode: $mode, onComplete: {}, onClose: {})
}
