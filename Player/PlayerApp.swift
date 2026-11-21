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
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var isSeeking = false
    private let canvas = CGSize(width: 360, height: 800)
    private let sliderStart: CGFloat = 30
    private let sliderEnd: CGFloat = 330
    private let tick = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var fraction: Double {
        duration > 0 ? min(1, max(0, currentTime / duration)) : 0
    }

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / canvas.width, geo.size.height / canvas.height)
            ZStack(alignment: .topLeading) {
                QwelExportedView(elapsed: formatted(currentTime),
                                 total: formatted(duration),
                                 seekX: sliderStart + (sliderEnd - sliderStart) * fraction,
                                 playing: isPlaying)
                    .allowsHitTesting(false)

                // Transparent interaction regions leave the original exported design intact.
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .frame(width: 312, height: 46)
                    .position(x: 180, y: 526)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isSeeking = true
                            seek(to: value.location.x / 312)
                        }
                        .onEnded { value in
                            seek(to: value.location.x / 312)
                            isSeeking = false
                        })

                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .frame(width: 96, height: 96)
                    .position(x: 180, y: 652)
                    .onTapGesture { togglePlayback() }

                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .frame(width: 64, height: 64)
                    .position(x: 72, y: 652)
                    .onTapGesture { skip(by: -10) }

                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .frame(width: 64, height: 64)
                    .position(x: 288, y: 652)
                    .onTapGesture { skip(by: 10) }
            }
            .frame(width: canvas.width, height: canvas.height)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: canvas.width * scale, height: canvas.height * scale)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .onAppear { prepareAudio() }
        .onReceive(tick) { _ in
            guard !isSeeking, let audio else { return }
            currentTime = audio.currentTime
            duration = audio.duration
            isPlaying = audio.isPlaying
        }
    }

    private func formatted(_ seconds: TimeInterval) -> String {
        let n = max(0, Int(seconds))
        return "\(n / 60):" + String(format: "%02d", n % 60)
    }

    private func prepareAudio() {
        guard audio == nil, let url = Bundle.main.url(forResource: "demo", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            audio = player
            duration = player.duration
        } catch {
            print("Player audio initialization failed: \(error)")
        }
    }

    private func togglePlayback() {
        prepareAudio()
        guard let audio else { return }
        if audio.isPlaying { audio.pause() } else { audio.play() }
        isPlaying = audio.isPlaying
        currentTime = audio.currentTime
    }

    private func seek(to relative: CGFloat) {
        prepareAudio()
        guard let audio, audio.duration > 0 else { return }
        let ratio = min(1, max(0, relative))
        audio.currentTime = Double(ratio) * audio.duration
        currentTime = audio.currentTime
    }

    private func skip(by seconds: TimeInterval) {
        prepareAudio()
        guard let audio else { return }
        audio.currentTime = max(0, min(audio.duration, audio.currentTime + seconds))
        currentTime = audio.currentTime
    }
}
