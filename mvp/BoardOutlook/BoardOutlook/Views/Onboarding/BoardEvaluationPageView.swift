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
        HStack {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.darkerGrotesque(size: 20))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.onboardingButtonBackground)
                }
                                
                Rectangle()
                    .fill(.opacity(0))
            
                Text("Board Evaluation")
                    .font(.darkerGrotesque(size: 30))
                    .fontWeight(.semibold)

                Text("30 mins")
                    .font(.darkerGrotesque(size: 18))
                    .fontWeight(.semibold)
                    .padding(.bottom, 30)

                Text("I am an AI interviewer with full context\nfrom your BoardOutlook run Board\nEvaluations.")
                    .font(.sfProTextRegular(size: 16))
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 100)
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.darkerGrotesque(size: 20))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.onboardingButtonForeground)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.onboardingButtonBackground)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 32)
    }
}


#Preview {
    BoardEvaluationPageView (onSkip: {}, onNext: {})
}
