//
//  LoadingStateView.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

import SwiftUI
import AVFoundation

struct TransitionView: View {
    @State private var countdownNumber: Int = 5
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playerDelegate: AVPlayerDelegate?
    
    @Binding var homeScreenState: HomeScreenViewState
    @Binding var isListening: Bool
    
    var audioBase64String: String?
    
    var onNext: () -> Void
    
    var body: some View {
        ZStack() {
            if (homeScreenState == .countdown) {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        Text(String(countdownNumber))
                            .font(.sfProTextRegular(size: 64))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.3), value: countdownNumber)

                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack() {
                if (homeScreenState == .preparing
                    || homeScreenState == .introduction
                    || homeScreenState == .countdown
                    || homeScreenState == .playingQuestion
                    || homeScreenState == .waitingForResponse) {
                    Spacer()
                    
                    if (homeScreenState == .countdown) {
                        Text("Start the interview in...")
                            .font(.sfProTextRegular(size: 16))
                            .foregroundStyle(.white)
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    StaticMicView()
                        .padding(.bottom, 30)
                } else if (homeScreenState == .microphoneSetUp
                            || homeScreenState == .obtainMicrophonePermission
                            || homeScreenState == .askForGettingReady
                            || homeScreenState == .userIsReady
                            || homeScreenState == .waitForAnswer
                            || homeScreenState == .answering) {
                    Spacer()
                    
                    
                    if ((homeScreenState == .askForGettingReady
                         || homeScreenState == .userIsReady
                         || homeScreenState == .answering)
                        && isListening) {
                        Spacer()
                        
                        Text("I'm listening...")
                            .font(.sfProTextRegular(size: 16))
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    
                    MicView(
                        isListening: $isListening,
                        onTap: onNext
                    )
                    .padding(.bottom, 30)
                }
            }

        }
        .onAppear {
            if (homeScreenState == .countdown) {
                startCountdown()
            } else if (homeScreenState == .playingQuestion) {
                if let audioBase64String = audioBase64String {
                    playAudioFromBase64(audioBase64String)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onNext()
                    }
                }
            } else if (homeScreenState == .loading
                        || homeScreenState == .preparing
                        || homeScreenState == .introduction) {
                DispatchQueue.main.asyncAfter (
                    deadline: .now() + 2.0
                ) {
                    onNext()
                }
            }
        }
    }
    
    func startCountdown() {
        countdownNumber = 5
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.invalidate()
                onNext()
            }
        }
    }
    
    func playAudioFromBase64(_ base64String: String) {
        guard let audioData = Data(base64Encoded: base64String) else {
            print("Failed to decode Base64 audio data")
            onNext() // Call onNext if data decoding fails
            return
        }
        
        do {
            // Create an audio player with the decoded data
            audioPlayer = try AVAudioPlayer(data: audioData)
            
            // Create and store the delegate
            playerDelegate = AVPlayerDelegate(onCompletion: onNext)
            audioPlayer?.delegate = playerDelegate
            
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to initialize audio player: \(error)")
            onNext() // Call onNext if audio playback fails
        }
    }
}

class AVPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onCompletion: () -> Void
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
        super.init()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onCompletion()
    }
}

#Preview {
    @Previewable @State var homeScreenState: HomeScreenViewState = .countdown
    @Previewable @State var isListening: Bool = false
    
    TransitionView(
        homeScreenState: $homeScreenState,
        isListening: $isListening,
        onNext: {}
    )
}
