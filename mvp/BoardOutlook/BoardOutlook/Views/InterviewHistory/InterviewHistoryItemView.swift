//
//  InterviewHistoryItemView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

import SwiftUI

struct InterviewHistoryItemView: View {
    var interviewHistoryItem: InterviewHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(interviewHistoryItem.title)
                .font(.darkerGrotesque(size: 20))
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            
            Text("Interview time: \(interviewHistoryItem.duration) minutes")
                .font(.darkerGrotesque(size: 16))
            
            Text(interviewHistoryItem.date)
                .font(.darkerGrotesque(size: 16))
                .padding(.bottom, 30)
            
            Button(action: { self.switchToInterviewSummaryScreen(with: interviewHistoryItem.interviewSummary) }) {
                Text("View summary")
                    .font(.darkerGrotesque(size: 16))
                    .fontWeight(.semibold)
                    .frame(width: 180, height: 40) // Adjusted height
                    .foregroundColor(.onboardingButtonForeground)
                    .background(.onboardingButtonBackground)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.onboardingButtonForeground)
        .cornerRadius(16)
        .border(.onboardingButtonForeground, width: 0.5)
    }
    
    private func switchToInterviewSummaryScreen(with interviewSummaryItems: [InterviewSummaryItem]) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        let interviewSummary = InterviewSummary(interviewSummary: interviewSummaryItems)
        let interviewSummaryView = InterviewSummaryView(interviewSummary: interviewSummary)
        window.rootViewController = UIHostingController(rootView: interviewSummaryView)
        window.makeKeyAndVisible()
    }
}

#Preview {
    InterviewHistoryItemView(
        interviewHistoryItem: InterviewHistoryItem(
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
        )
    )
}
