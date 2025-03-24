//
//  BackgroundCircleView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//
import SwiftUI

struct BackgroundCircleView: View {
    let colorInHex: Int
    let opacity: Double
    let frameWidthFactor: Double
    let positionXFactor: Double
    let positionYFactor: Double
    
    var body: some View {
        Circle()
            .fill(Color(hex: colorInHex, opacity: opacity))
            .frame(width: UIScreen.main.bounds.width * frameWidthFactor)
            .position(x: UIScreen.main.bounds.width * positionXFactor, y: UIScreen.main.bounds.height * positionYFactor)
    }
}
