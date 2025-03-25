//
//  ToolbarView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct ToolbarView : View {
    @Binding var selectedMode: InterviewMode

    var onClose: () -> Void
    
    var body: some View {
        HStack {
            VoiceTextToggleView(selectedMode: $selectedMode)
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    @Previewable @State var mode = InterviewMode.voice
    
    return ToolbarView(selectedMode: $mode) {
    }

}
