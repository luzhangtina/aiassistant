//
//  BulletPointTextView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct BulletPointTextView: View {
    var text: String
    var fontSize: CGFloat = 16
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(.onboardingButtonBackground)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.sfProTextRegular(size: fontSize))
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        BulletPointTextView(text: "Test bullet point text with a very long description?")
        BulletPointTextView(text: "Test bullet point text second line")
        BulletPointTextView(text: "Does it display correctly?")
    }
    .padding()
}
