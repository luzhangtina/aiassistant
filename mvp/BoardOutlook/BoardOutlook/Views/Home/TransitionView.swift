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
                CountdownOverlay(countdownNumber: countdownNumber)
            }
            
            VStack() {
                switch homeScreenState {
                case .surveyIsCompleted:
                    SurveyCompletedView(onNext: onNext)
                case .preparing, .introduction, .countdown, .playingQuestion, .waitingForResponse:
                    NoMicphoneInteractionView(homeScreenState: homeScreenState)
                case .microphoneSetUp, .obtainMicrophonePermission, .askForGettingReady, .userIsReady, .waitForAnswer, .answering:
                    MicrophoneInteractionView(
                        homeScreenState: homeScreenState,
                        isListening: isListening,
                        onNext: onNext
                    )
                default:
                    EmptyView()
                }
            }

        }
        .onAppear(perform: handleOnAppear)
    }
    
    private func handleOnAppear() {
        switch homeScreenState {
        case .countdown:
            startCountdown()

        case .playingQuestion:
            if let audioBase64String = audioBase64String {
                playAudioFromBase64(audioBase64String)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: onNext)
            }

        case .loading, .preparing, .introduction:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: onNext)

        default: break
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
    @Previewable @State var homeScreenState: HomeScreenViewState = .surveyIsCompleted
    @Previewable @State var isListening: Bool = false
    
    TransitionView(
        homeScreenState: $homeScreenState,
        isListening: $isListening,
        onNext: {}
    )
}
