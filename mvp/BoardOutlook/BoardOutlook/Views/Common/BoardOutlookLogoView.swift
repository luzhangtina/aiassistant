//
//  BoardOutlookLogoView.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//
import SwiftUI

struct BoardOutlookLogoView: View {
    var body: some View {
        HStack {
            Text("BoardOutlook")
                .font(.oxanium(size: 22.5))
                .fontWeight(.semibold)
            Image(systemName: "sparkles")
        }
    }
}
