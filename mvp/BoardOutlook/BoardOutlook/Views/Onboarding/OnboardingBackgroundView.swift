//
//  OnboardingBackgroundView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct OnboardingBackgroundView: View {
    var body: some View {
        ZStack {
            BackgroundCircleView(colorInHex: 0xf8f4ee, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.39, positionYFactor: 0.1)
            BackgroundCircleView(colorInHex: 0xe9f3fd, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.04, positionYFactor: 0.45)
            BackgroundCircleView(colorInHex: 0xefeafa, opacity: 0.6, frameWidthFactor: 1.01, positionXFactor: 0.96, positionYFactor: 0.24)
        }
    }
}

#Preview {
    OnboardingBackgroundView()
}
