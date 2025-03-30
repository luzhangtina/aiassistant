//
//  WelcomePageView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Spacer()
        
            BoardOutlookLogoView()
                .padding(.bottom, 30)
            
            Text("Welcome to the BoardOutlook Interview")
                .font(.darkerGrotesque(size: 40))
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 100)
        }
    }
}


#Preview {
    WelcomePageView()
}
