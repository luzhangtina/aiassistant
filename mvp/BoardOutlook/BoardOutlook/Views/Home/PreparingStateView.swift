//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI

struct PreparingStateView: View {
    var onComplete: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 10
        ) {
            HStack {
                Capsule()
                    .fill(.white)
                    .frame(width: 160, height: 40)
                    .overlay(
                        HStack(spacing: 0) {
                            Text("Voice")
                                .font(.sfProTextRegular(size: 13))
                                .fontWeight(.medium)
                                .background(Capsule().fill(.white))
                                .foregroundStyle(.black)
                            Text("Text")
                                .font(.sfProTextRegular(size: 13))
                                .fontWeight(.medium)
                                .foregroundStyle(.black)
                        }
                    )
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
                .foregroundStyle(.white)
            }
            .padding(.bottom, 60)
            
            Text("Board Evaluation")
                .font(.sfProTextRegular(size: 32))
                .foregroundStyle(.white)
            
            Text("30 mins")
                .font(.sfProTextRegular(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("One moment...")
                .font(.sfProTextRegular(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 68, height: 68)
                
                Image(systemName: "microphone.fill")
            }
            .padding(.bottom, 20)
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
    PreparingStateView(onComplete: {}, onClose: {})
}
