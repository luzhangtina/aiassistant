//
//  InterviewSummaryView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

import SwiftUI

struct InterviewSummaryView: View {
    var interviewSummary: InterviewSummary = InterviewSummary(interviewSummary: [
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
        ),
    ])
    
    var body: some View {
        ZStack {
            LightBackgroundBackgroundView()
            
            VStack(alignment: .leading, spacing: 10) {
                SummaryScreenToolbarView(onClose: changeRootViewToInterviewHistoryScreen)
                .padding(.bottom, 20)
                
                Text("Here's a high level ")
                    .font(.darkerGrotesque(size: 20)) +
                Text("summary")
                    .font(.darkerGrotesque(size: 20))
                    .fontWeight(.bold) +
                Text(" of our discussion")
                    .font(.darkerGrotesque(size: 20))
                
                Text("Interview time: 29 minutes")
                    .font(.darkerGrotesque(size: 18))
                    .fontWeight(.semibold)

                Spacer()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(interviewSummary.interviewSummary, id: \.self.title) { item in
                            InterviewSummaryItemView(interviewSummaryItem: item)
                                .padding(.bottom, 20)
                        }
                    }
                }
                
            }
            .padding(.horizontal, 32)
        }
    }
    
    private func changeRootViewToInterviewHistoryScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        // Set the new root view controller to HomeScreenView
        window.rootViewController = UIHostingController(rootView: InterviewHistoryView())
        window.makeKeyAndVisible()
    }

}

#Preview {
    InterviewSummaryView()
}
