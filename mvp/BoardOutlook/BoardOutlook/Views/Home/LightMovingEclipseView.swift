//
//  EclipseView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct LightMovingEclipseView: View {
    @State private var animateGradient = false
    
    var body: some View {
        GeometryReader { geometry in
            Ellipse()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: 0x2a4e9a),
                            Color(hex: 0x2a468f)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(1), .white.opacity(0.4)]),
                        startPoint: animateGradient ? .leading : .trailing,
                        endPoint: animateGradient ? .trailing : .leading
                    ),
                    lineWidth: 10
                )
                .mask(Ellipse())
                .frame(
                    width: geometry.size.width * 1.3,
                    height: geometry.size.height * 0.4
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.95
                )
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false)) {
                        animateGradient = true
                    }
                }
        }
    }
}

#Preview {
    LightMovingEclipseView()
}
