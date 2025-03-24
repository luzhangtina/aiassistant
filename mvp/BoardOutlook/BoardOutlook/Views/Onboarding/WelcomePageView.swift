//
//  WelcomePageView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct WelcomePageView: View {
    var onButtonPress: () -> Void
    
    var body: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                Spacer()
            
                HStack {
                    Text("BoardOutlook")
                        .font(.oxanium(size: 22.5))
                        .fontWeight(.semibold)
                    Image(systemName: "sparkles")
                }
                .padding(.bottom, 30)
                
                Text("Welcome to the\nBoardOutlook\nInterview")
                    .font(.darkerGrotesque(size: 42))
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: onButtonPress) {
                    HStack {
                        Text("Get started")
                            .font(.darkerGrotesque(size: 20))
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.onboardingButtonForeground)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.onboardingButtonBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 32)
    }
}


#Preview {
    WelcomePageView {
        
    }
}
