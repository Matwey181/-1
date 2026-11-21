import SwiftUI
import AVFoundation
import MediaPlayer

@MainActor
final class AudioModel: ObservableObject {
    @Published var isPlaying = false
    @Published var current = 0.0
    @Published var duration = 1.0
    @Published var looping = false
    @Published var favorite = false
    private var audio: AVAudioPlayer?
    private var ticker: Timer?

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            if let url = Bundle.main.url(forResource: "demo", withExtension: "wav") {
                audio = try AVAudioPlayer(contentsOf: url)
                audio?.prepareToPlay()
                duration = max(audio?.duration ?? 1, 1)
            }
        } catch { print("Audio error: \(error)") }
        ticker = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
        let remote = MPRemoteCommandCenter.shared()
        remote.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        remote.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        remote.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let e = event as? MPChangePlaybackPositionCommandEvent {
                Task { @MainActor in self?.seek(e.positionTime) }
            }
            return .success
        }
    }
    func play() {
        if (audio?.currentTime ?? 0) >= duration { audio?.currentTime = 0 }
        isPlaying = audio?.play() ?? false
        nowPlaying()
    }
    func pause() { audio?.pause(); isPlaying = false; nowPlaying() }
    func toggle() { isPlaying ? pause() : play() }
    func seek(_ value: Double) {
        audio?.currentTime = max(0, min(duration, value))
        current = audio?.currentTime ?? 0
        nowPlaying()
    }
    func skipBack() { seek(max(0, current - 10)) }
    func skipForward() { seek(min(duration, current + 10)) }
    private func update() {
        guard let audio else { return }
        current = audio.currentTime
        if isPlaying && !audio.isPlaying {
            if looping { audio.currentTime = 0; isPlaying = audio.play() }
            else { isPlaying = false; audio.currentTime = 0; current = 0 }
        }
        nowPlaying()
    }
    private func nowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "Тестовая мелодия",
            MPMediaItemPropertyArtist: "Demo Player",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: current,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
}

struct PlayerView: View {
    @StateObject private var model = AudioModel()
    private let plum = Color(red: 0.58, green: 0.22, blue: 0.38)
    private let pink = Color(red: 0.98, green: 0.83, blue: 0.88)
    private let ink = Color(red: 0.18, green: 0.15, blue: 0.18)
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "chevron.down")
                    Spacer()
                    Text("Сейчас играет").font(.system(size: 15, weight: .medium))
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                .font(.system(size: 21, weight: .semibold))
                .padding(.horizontal, 30).padding(.top, 18)
                Spacer(minLength: 20)
                ZStack {
                    RoundedRectangle(cornerRadius: 52).fill(pink)
                    RoundedRectangle(cornerRadius: 45).fill(.white.opacity(0.15)).padding(16)
                    Circle().fill(plum).padding(64)
                    Image(systemName: "waveform").font(.system(size: 54)).foregroundStyle(.white)
                }
                .frame(width: min(geo.size.width - 64, 320), height: min(geo.size.width - 64, 320))
                Spacer(minLength: 28)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Тестовая мелодия").font(.system(size: 23, weight: .semibold))
                            Text("Demo Player").font(.system(size: 15)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { model.favorite.toggle() } label: {
                            Image(systemName: model.favorite ? "heart.fill" : "heart")
                                .font(.system(size: 24)).foregroundStyle(plum)
                        }
                    }
                    Slider(value: Binding(get: { model.current }, set: { model.seek($0) }), in: 0...max(model.duration, 0.1)).tint(plum).padding(.top, 12)
                    HStack {
                        Text(time(model.current))
                        Spacer()
                        Text(time(model.duration))
                    }.font(.system(size: 12)).foregroundStyle(.secondary)
                }.padding(.horizontal, 32)
                Spacer(minLength: 20)
                HStack(spacing: 30) {
                    Button(action: model.skipBack) {
                        Image(systemName: "gobackward.10").font(.system(size: 27))
                            .frame(width: 60, height: 60).background(pink.opacity(0.7), in: Circle())
                    }
                    Button(action: model.toggle) {
                        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32)).foregroundStyle(.white)
                            .frame(width: 90, height: 90)
                            .background(plum, in: RoundedRectangle(cornerRadius: 29))
                    }
                    Button(action: model.skipForward) {
                        Image(systemName: "goforward.10").font(.system(size: 27))
                            .frame(width: 60, height: 60).background(pink.opacity(0.7), in: Circle())
                    }
                }.buttonStyle(.plain).foregroundStyle(ink)
                Spacer(minLength: 22)
                HStack {
                    Image(systemName: "shuffle").foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "airplay.audio").foregroundStyle(.secondary)
                    Spacer()
                    Button { model.looping.toggle() } label: {
                        Image(systemName: "repeat").foregroundStyle(model.looping ? plum : ink)
                    }
                    Spacer()
                    Image(systemName: "list.bullet").foregroundStyle(.secondary)
                }
                .font(.system(size: 21))
                .padding(.horizontal, 44).padding(.bottom, 34)
            }.foregroundStyle(ink).frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background(Color(red: 1, green: 0.985, blue: 0.99))
    }
    private func time(_ seconds: Double) -> String {
        let s = Int(seconds.isFinite ? max(0, seconds) : 0)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
