//
//  WelcomePageView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct YouAreInControlPageView: View {
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Rectangle()
                .fill(.opacity(0))
        
            Text("You are in complete control")
                .font(.darkerGrotesque(size: 25))
                .fontWeight(.semibold)

            BulletPointTextView(text: "You can check in on the interview timing at any point")

            BulletPointTextView(text: "Pause and return later at anytime")
            
            BulletPointTextView(text: "Choose how deep to go in responding to questions")

            Spacer(minLength: 70)
        }
    }
}


#Preview {
    YouAreInControlPageView ()
}
