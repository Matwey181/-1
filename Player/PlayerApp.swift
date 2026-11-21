import SwiftUI
import AVFoundation

@main
struct PlayerApp: App {
    var body: some Scene {
        WindowGroup { OriginalPlayerScreen() }
    }
}

struct OriginalPlayerScreen: View {
    @State private var audio: AVAudioPlayer?
    @State private var isPlaying = false
    private let canvas = CGSize(width: 360, height: 800)

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / canvas.width, geo.size.height / canvas.height)
            ZStack(alignment: .topLeading) {
                QwelExportedView()
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: 96, height: 96)
                    .position(x: 180, y: 652)
                    .onTapGesture { togglePlayback() }
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: 64, height: 64)
                    .position(x: 72, y: 652)
                    .onTapGesture { restart() }
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: 64, height: 64)
                    .position(x: 288, y: 652)
                    .onTapGesture { restart() }
            }
            .frame(width: canvas.width, height: canvas.height)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: canvas.width * scale, height: canvas.height * scale)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .onAppear { prepareAudio() }
    }

    private func prepareAudio() {
        guard audio == nil, let url = Bundle.main.url(forResource: "demo", withExtension: "wav") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        audio = try? AVAudioPlayer(contentsOf: url)
        audio?.numberOfLoops = -1
        audio?.prepareToPlay()
    }

    private func togglePlayback() {
        prepareAudio()
        guard let audio else { return }
        if audio.isPlaying { audio.pause() } else { audio.play() }
        isPlaying = audio.isPlaying
    }

    private func restart() {
        prepareAudio()
        audio?.currentTime = 0
        audio?.play()
        isPlaying = audio?.isPlaying ?? false
    }
}
