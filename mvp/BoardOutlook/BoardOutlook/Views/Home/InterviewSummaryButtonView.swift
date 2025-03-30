//
//  NextButtonView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//
import SwiftUI

struct InterviewSummaryButtonView: View {
    var onNext : () -> Void
    
    var body: some View {
        Button(action: onNext) {
            HStack {
                Text("View Intetrview Summary")
                    .font(.darkerGrotesque(size: 20))
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity, maxHeight: 48)
            .foregroundStyle(Color(hex: 0x18146c))
            .background(LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(hex: 0xfcfcfc, opacity: 0.85),
                        Color(hex: 0xfcfcfc)
                    ]
                ),
                startPoint: .top, endPoint: .bottom))
            .cornerRadius(12)
            .border(Color(hex: 0x18146c), width: 0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: 48)
        .contentShape(Rectangle())
    }
}

#Preview {
    InterviewSummaryButtonView{
        
    }
}

