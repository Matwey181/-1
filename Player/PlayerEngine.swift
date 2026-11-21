import SwiftUI
import AVFoundation

@MainActor
final class PlayerEngine: ObservableObject {
    struct Track {
        let url: URL
        let name: String
        let demo: Bool
    }

    @Published private(set) var isPlaying = false
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var title = "Название трека"
    @Published private(set) var artist = "Название группы"
    @Published private(set) var trackNames: [String] = []
    @Published private(set) var selectedTrack = 0
    @Published var errorMessage: String?

    private var tracks: [Track] = []
    private var audio: AVAudioPlayer?
    private var prepared = false

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, elapsed / duration))
    }

    func prepare() {
        guard !prepared else { return }
        prepared = true
        guard let demoURL = Bundle.main.url(forResource: "demo", withExtension: "wav") else {
            errorMessage = "Тестовая мелодия demo.wav не попала в приложение."
            return
        }
        tracks.append(Track(url: demoURL, name: "Название трека", demo: true))
        trackNames = tracks.map(\.name)
        openTrack(0, autoplay: false)
    }

    private func openTrack(_ index: Int, autoplay: Bool) {
        guard tracks.indices.contains(index) else { return }
        audio?.stop()
        let track = tracks[index]
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: track.url)
            newPlayer.numberOfLoops = tracks.count == 1 ? -1 : 0
            newPlayer.prepareToPlay()
            audio = newPlayer
            selectedTrack = index
            elapsed = 0
            duration = newPlayer.duration
            title = track.name
            artist = track.demo ? "Название группы" : "Локальная музыка"
            isPlaying = autoplay ? newPlayer.play() : false
            errorMessage = nil
        } catch {
            audio = nil
            isPlaying = false
            errorMessage = "Не удалось воспроизвести аудио: \(error.localizedDescription)"
        }
    }

    func toggle() {
        prepare()
        guard let audio else { return }
        if audio.isPlaying {
            audio.pause()
            isPlaying = false
        } else {
            if audio.currentTime >= audio.duration { audio.currentTime = 0 }
            isPlaying = audio.play()
        }
        elapsed = audio.currentTime
    }

    func seek(to fraction: Double) {
        prepare()
        guard let audio, audio.duration > 0 else { return }
        audio.currentTime = min(1, max(0, fraction)) * audio.duration
        elapsed = audio.currentTime
    }

    func step(_ seconds: TimeInterval) {
        prepare()
        guard let audio else { return }
        audio.currentTime = min(audio.duration, max(0, audio.currentTime + seconds))
        elapsed = audio.currentTime
    }

    func previous() {
        if tracks.count > 1 {
            openTrack((selectedTrack - 1 + tracks.count) % tracks.count, autoplay: isPlaying)
        } else {
            step(-10)
        }
    }

    func next() {
        if tracks.count > 1 {
            openTrack((selectedTrack + 1) % tracks.count, autoplay: isPlaying)
        } else {
            step(10)
        }
    }

    func selectTrack(_ index: Int) {
        openTrack(index, autoplay: true)
    }

    func refresh() {
        guard let audio else { return }
        elapsed = audio.currentTime
        duration = audio.duration
        if isPlaying && !audio.isPlaying && tracks.count > 1 &&
            audio.currentTime >= audio.duration - 0.15 {
            next()
        } else {
            isPlaying = audio.isPlaying
        }
    }

    func importAudio(_ urls: [URL]) throws {
        prepare()
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImportedAudio", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var added = false
        for url in urls {
            let secured = url.startAccessingSecurityScopedResource()
            defer { if secured { url.stopAccessingSecurityScopedResource() } }
            let destination = folder.appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(url.pathExtension)
            try FileManager.default.copyItem(at: url, to: destination)
            let name = url.deletingPathExtension().lastPathComponent
            tracks.append(Track(url: destination, name: name, demo: false))
            added = true
        }
        if added {
            trackNames = tracks.map(\.name)
            openTrack(tracks.count - 1, autoplay: true)
        }
    }

    func timeLabel(_ time: TimeInterval) -> String {
        let count = max(0, Int(time))
        return String(format: "%d:%02d", count / 60, count % 60)
    }
}
