//
//  InterviewSummaryItemView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

import SwiftUI

struct InterviewSummaryItemView: View {
    let interviewSummaryItem: InterviewSummaryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Text(interviewSummaryItem.title)
                    .font(.darkerGrotesque(size: 20))
                    .fontWeight(.semibold)
                ForEach(interviewSummaryItem.details, id: \.self) { detail in
                    BulletPointTextView(
                        text: detail,
                        fontSize: 14
                    )
                    .padding(.leading, 10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(.onboardingButtonForeground)
        .cornerRadius(16)
        .border(.onboardingButtonForeground, width: 0.5)
    }
}

#Preview {
    InterviewSummaryItemView(interviewSummaryItem: InterviewSummaryItem(
        title: "Key Board Strengths",
        details: [
            "The strategy is focused on where to compete and win, not operational issues",
            "The Board devotes appropriate time and energy to risk management"
        ]))
}
