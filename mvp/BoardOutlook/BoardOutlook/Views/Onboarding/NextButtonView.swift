//
//  NextButtonView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//
import SwiftUI

struct NextButtonView: View {
    var onNext : () -> Void
    
    var body: some View {
        Button(action: onNext) {
            Text("Next")
                .font(.darkerGrotesque(size: 20))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .foregroundColor(.onboardingButtonForeground)
                .background(.onboardingButtonBackground)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: 48)
        .contentShape(Rectangle())
    }
}

#Preview {
    NextButtonView{
        
    }
}

