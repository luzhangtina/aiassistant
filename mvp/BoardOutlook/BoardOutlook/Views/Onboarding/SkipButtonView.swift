//
//  SkipButton.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct SkipButtonView: View {
    var onSkip : () -> Void
    var body: some View {
        HStack {
            Spacer()
            Button(action: onSkip) {
                Text("Skip")
                    .font(.darkerGrotesque(size: 20))
                    .fontWeight(.semibold)
            }
            .foregroundColor(.onboardingButtonBackground)
        }
    }
}

#Preview {
    SkipButtonView {
        
    }
}
