//
//  InterviewHistoryView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

import SwiftUI

struct InterviewHistoryView: View {
    var interviewHistory: InterviewHistory = InterviewHistory(interviewHistory: [
        InterviewHistoryItem(
            title: "Board Evaluation 2025",
            duration: 29,
            date: "20 March 2025",
            interviewSummary: [
                InterviewSummaryItem(
                    title: "Key Board Strengths",
                    details: [
                        "The strategy is focused on where to compete and win, not operational issues",
                        "The Board devotes appropriate time and energy to risk management"
                    ]
                ),
                InterviewSummaryItem(
                    title: "Improvement Areas",
                    details: [
                        "Oversight of reputational risks",
                        "Engagement and positioning with goverment"
                    ]
                ),
                InterviewSummaryItem(
                    title: "Areas for deeper discussion",
                    details: [
                        "The Board is treated as a partner in the strategy process",
                        "Oversight of regulatory risks"
                    ]
                )
            ]
        ),
        InterviewHistoryItem(
            title: "Committee Evaluation 2025",
            duration: 29,
            date: "18 February 2025",
            interviewSummary: [
                InterviewSummaryItem(
                    title: "Key Committee Strengths",
                    details: [
                        "The strategy is focused on where to compete and win, not operational issues",
                        "The committee devotes appropriate time and energy to risk management"
                    ]
                )
            ]
        )
    ])
    
    var body: some View {
        ZStack {
            LightBackgroundBackgroundView()
            
            VStack(alignment: .leading, spacing: 10) {
                BoardOutlookLogoView()
                .padding(.bottom, 20)

                Spacer()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(interviewHistory.interviewHistory, id: \.self.title) { item in
                            InterviewHistoryItemView(
                                interviewHistoryItem: item
                            )
                            .padding(.bottom, 20)
                        }
                    }
                }
                
            }
            .padding(.horizontal, 32)
        }

    }
}

#Preview {
    InterviewHistoryView()
}
