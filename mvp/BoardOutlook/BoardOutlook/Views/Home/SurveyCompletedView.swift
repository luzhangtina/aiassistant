//
//  SurveyCompletedView.swift
//  BoardOutlook
//
//  Created by lu on 14/4/2025.
//

import SwiftUI

struct SurveyCompletedView: View {
    var onNext: () -> Void

    var body: some View {
        Spacer()
        Text("That's it!").font(.sfProTextRegular(size: 30)).foregroundStyle(.white)
        Text("Thanks for your time.").font(.sfProTextRegular(size: 30)).foregroundStyle(.white)
        Spacer()
        Spacer()
        InterviewSummaryButtonView(onNext: onNext).padding(.bottom, 30)
    }
}

#Preview {
    SurveyCompletedView(onNext: {})
}
