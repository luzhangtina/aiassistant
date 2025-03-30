//
//  ToolbarView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

import SwiftUI

struct SummaryScreenToolbarView : View {
    var onClose: () -> Void
    
    var body: some View {
        HStack {
            BoardOutlookLogoView()
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .foregroundStyle(.onboardingButtonBackground)
        }
    }
}

#Preview {
    SummaryScreenToolbarView(onClose: {})
}
