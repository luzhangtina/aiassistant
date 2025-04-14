//
//  CountdownOverlay.swift
//  BoardOutlook
//
//  Created by lu on 14/4/2025.
//
import SwiftUI

struct CountdownOverlay: View {
    var countdownNumber: Int

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Text(String(countdownNumber))
                    .font(.sfProTextRegular(size: 64))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.3), value: countdownNumber)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    CountdownOverlay(countdownNumber: 5)
}
