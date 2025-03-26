//
//  EclipseView.swift
//  BoardOutlook
//
//  Created by lu on 25/3/2025.
//

import SwiftUI

struct AudioEclipseView: View {
    @State private var animateGradient = false
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.7),
                                .white.opacity(1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: geometry.size.width * dynamicWidth(),
                        height: geometry.size.height * dynamicHeight()
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(),
                        y: geometry.size.height * 0.95
                    )
                    .onReceive(timer) { input in
                        currentTime = input
                    }
            }
            
            GeometryReader { geometry in
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.8),
                                .white.opacity(1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: geometry.size.width * dynamicWidth() * 1.3,
                        height: geometry.size.height * dynamicHeight()
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition() + 170,
                        y: geometry.size.height * 0.93
                    )
                    .onReceive(timer) { input in
                        currentTime = input
                    }
            }


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
                            gradient: Gradient(colors: [.white.opacity(1), .white.opacity(1)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 10
                    )
                    .mask(Ellipse())
                    .frame(
                        width: geometry.size.width * 1.5,
                        height: geometry.size.height * 0.35
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
    
    func dynamicWidth() -> CGFloat {
        let baseWidth: CGFloat = 0.5
        let amplitude: CGFloat = 0.2
        let frequency: CGFloat = 2
        
        return baseWidth + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
    
    func dynamicHeight() -> CGFloat {
        let baseHeight: CGFloat = 0.4
        let amplitude: CGFloat = 0.05
        let frequency: CGFloat = 15
        
        return baseHeight + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
    
    func dynamicXPosition() -> CGFloat {
        let basePosition: CGFloat = 0.25
        let amplitude: CGFloat = 0.15
        let frequency: CGFloat = 2
        
        return basePosition + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
}

#Preview {    
    AudioEclipseView()
}
