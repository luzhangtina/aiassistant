//
//  WelcomePageView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct InteractiveExperiencePageView: View {
    var onSkip: () -> Void
    var onNext: () -> Void
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            SkipButtonView(onSkip: onSkip)
            Rectangle()
                .fill(.opacity(0))
        
            Text("Interactive experience")
                .font(.darkerGrotesque(size: 25))
                .fontWeight(.semibold)

            BulletPointTextView(text: "BoardOutlook Interviewer defaults to voice interactions and we encourage you to give it a try")

            BulletPointTextView(text: "Alternatively you can select text responses if you prefer")

            Spacer(minLength: 70)
            
            NextButtonView(onNext: onNext)
        }
    }
}


#Preview {
    InteractiveExperiencePageView (onSkip: {}, onNext: {})
}
