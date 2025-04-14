//
//  InterviewHeader.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct InterviewHeader: View {
    @Binding var title: String
    @Binding var estimatedDuration: Int
    @Binding var durationUnit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.sfProTextRegular(size: 32))
                .foregroundStyle(.white)
                .padding(.top, 60)

            Text("\(estimatedDuration) \(durationUnit)s")
                .font(.sfProTextRegular(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.top, 20)
        }
    }
}

#Preview {
    @Previewable @State var title: String = "Board Evaluation"
    @Previewable @State var estimatedDuration: Int = 30
    @Previewable @State var durationUnit: String = "minute"
    
    InterviewHeader(
        title: $title,
        estimatedDuration: $estimatedDuration,
        durationUnit: $durationUnit
    )
}

