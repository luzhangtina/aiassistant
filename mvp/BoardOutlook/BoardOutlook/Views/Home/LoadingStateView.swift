//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct LoadingStateView: View {
    var onComplete: () -> Void
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 10
        ) {
        }
        .onAppear {
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 2.0
            ) {
                onComplete()
            }
        }
    }
}

#Preview {
    LoadingStateView{
        
    }
}
