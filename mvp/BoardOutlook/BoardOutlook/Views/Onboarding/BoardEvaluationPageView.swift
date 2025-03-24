//
//  WelcomePageView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct BoardEvaluationPageView: View {
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
        
            Text("Board Evaluation")
                .font(.darkerGrotesque(size: 30))
                .fontWeight(.semibold)

            Text("30 mins")
                .font(.darkerGrotesque(size: 18))
                .fontWeight(.semibold)
                .padding(.bottom, 30)

            Text("I am an AI interviewer with full context from your BoardOutlook run Board Evaluations.")
                .font(.sfProTextRegular(size: 16))
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 70)
            
            NextButtonView(onNext: onNext)
        }
    }
}


#Preview {
    BoardEvaluationPageView (onSkip: {}, onNext: {})
}
