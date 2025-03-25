//
//  CenterTextView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct CenteredTextView: View {
    @Binding var text: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                Text(text)
                    .font(.sfProTextRegular(size: 16))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    CenteredTextView(text: .constant("This is a text to check if multi-line description works as expected"))
}
