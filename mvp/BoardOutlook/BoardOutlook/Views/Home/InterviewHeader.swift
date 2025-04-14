//
//  MicView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct InterviewHeader: View {
    var body: some View {
        VStack {
            Text("Board Evaluation")
                .font(.sfProTextRegular(size: 32))
                .foregroundStyle(.white)
                .padding(.top, 60)

            Text("30 mins")
                .font(.sfProTextRegular(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.top, 20)
        }
    }
}

#Preview {
    InterviewHeader()
}

