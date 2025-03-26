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
                        width: geometry.size.width * dynamicWidth(
                            baseWidth: 0.25,
                            frequency: 2,
                            amplitude: 0.1),
                        height: geometry.size.height * dynamicHeight(
                            baseHeight: 0.16,
                            frequency: 5,
                            amplitude: 0.2)
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(
                            basePosition: 0.25,
                            frequency: 7,
                            amplitude: 0.25
                        ),
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
                                .white.opacity(0.7),
                                .white.opacity(1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: geometry.size.width * dynamicWidth(
                            baseWidth: 0.25,
                            frequency: 2,
                            amplitude: 0.1),
                        height: geometry.size.height * dynamicHeight(
                            baseHeight: 0.16,
                            frequency: 5,
                            amplitude: 0.2)
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(
                            basePosition: 0.35,
                            frequency: 2,
                            amplitude: 0.15
                        ),
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
                        width: geometry.size.width * dynamicWidth(),
                        height: geometry.size.height * dynamicHeight(
                            baseHeight: 0.36,
                            frequency: 3)
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(
                            basePosition: 0.5,
                            frequency: 2,
                            amplitude: 0.13
                        ),
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
                        width: geometry.size.width * dynamicWidth(
                            baseWidth: 0.2,
                            frequency: 5,
                            amplitude: 0.2),
                        height: geometry.size.height * dynamicHeight(
                            baseHeight: 0.1,
                            frequency: 2,
                            amplitude: 0.3)
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(
                            basePosition: 0.65,
                            frequency: 3,
                            amplitude: 0.08
                        ),
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
                        width: geometry.size.width * dynamicWidth(
                            baseWidth: 0.2,
                            frequency: 5,
                            amplitude: 0.2),
                        height: geometry.size.height * dynamicHeight(
                            baseHeight: 0.1,
                            frequency: 2,
                            amplitude: 0.3)
                    )
                    .position(
                        x: geometry.size.width * dynamicXPosition(
                            basePosition: 0.77,
                            frequency: 7,
                            amplitude: 0.17
                        ),
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
    
    func dynamicWidth(
        baseWidth: CGFloat = 0.5,
        frequency: CGFloat = 2,
        amplitude: CGFloat = 0.2
    ) -> CGFloat {
        return baseWidth + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
    
    func dynamicHeight(
        baseHeight: CGFloat = 0.4,
        frequency: CGFloat = 15,
        amplitude: CGFloat = 0.05
    ) -> CGFloat {
        return baseHeight + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
    
    func dynamicXPosition(
        basePosition: CGFloat = 0.25,
        frequency: CGFloat = 2,
        amplitude: CGFloat = 0.15
    ) -> CGFloat {
        return basePosition + amplitude * sin(currentTime.timeIntervalSinceReferenceDate * frequency)
    }
}

#Preview {    
    AudioEclipseView()
}
