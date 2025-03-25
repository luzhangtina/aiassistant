//
//  ContentView.swift
//  BoardOutlook
//
//  Created by lu on 26/3/2025.
//

import SwiftUI
import WebKit

struct GifView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            let data = try? Data(contentsOf: url)
            uiView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }
    }
}

struct GlowingBallView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(hex: 0x3bb3fd),
                                Color(hex: 0x2e61e6)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            GifView(gifName: "GlowingBall")
                .clipShape(Circle())
                .blendMode(.screen)
        }
        .frame(width: 68, height: 68)
    }
}

#Preview {
    GlowingBallView()
}
