import SwiftUI
import UniformTypeIdentifiers

@main
struct PlayerApp: App {
    var body: some Scene {
        WindowGroup { OriginalPlayerScreen() }
    }
}

struct OriginalPlayerScreen: View {
    @StateObject private var player = PlayerEngine()
    @State private var importing = false
    @State private var showingLibrary = false
    @State private var showingOptions = false
    @State private var showingError = false
    @State private var errorText = ""
    @State private var dragging = false
    @State private var dragProgress: Double?
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 360, geometry.size.height / 800)
            ZStack {
                Color.white.ignoresSafeArea()
                interactiveArtwork
                    .frame(width: 360, height: 800)
                    .scaleEffect(scale, anchor: .center)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .background(Color.white)
        .preferredColorScheme(.light)
        .onAppear {
            player.prepare()
            if let message = player.errorMessage {
                errorText = message
                showingError = true
            }
        }
        .onReceive(clock) { _ in
            if !dragging { player.refresh() }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
            Task { @MainActor in
                switch result {
                case .success(let urls):
                    do { try player.importAudio(urls) }
                    catch {
                        errorText = error.localizedDescription
                        showingError = true
                    }
                case .failure(let error):
                    errorText = error.localizedDescription
                    showingError = true
                }
            }
        }
        .sheet(isPresented: $showingLibrary) {
            NavigationStack {
                List {
                    ForEach(player.trackNames.indices, id: \.self) { index in
                        Button {
                            player.selectTrack(index)
                            showingLibrary = false
                        } label: {
                            HStack {
                                Text(player.trackNames[index])
                                Spacer()
                                if player.selectedTrack == index {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundStyle(Color(red: 0.576, green: 0.235, blue: 0.365))
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Моя музыка")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") { showingLibrary = false }
                    }
                }
            }
        }
        .confirmationDialog("Плеер", isPresented: $showingOptions) {
            Button("Моя музыка") { showingLibrary = true }
            Button("Добавить музыку") { importing = true }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Не удалось воспроизвести аудио", isPresented: $showingError) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text(errorText)
        }
    }

    private var interactiveArtwork: some View {
        ZStack(alignment: .topLeading) {
            // Keep the source artwork and its 360 x 800 proportions intact.
            QwelExportedView(
                elapsed: player.timeLabel(player.elapsed),
                total: player.timeLabel(player.duration),
                progress: CGFloat(dragProgress ?? player.progress),
                playing: player.isPlaying,
                trackTitle: player.title,
                artist: player.artist
            )
            .frame(width: 360, height: 800)
            .allowsHitTesting(false)

            // True touch-driven scrubbing, not just an exported picture.
            Rectangle()
                .fill(Color.black.opacity(0.001))
                .frame(width: 320, height: 52)
                .contentShape(Rectangle())
                .position(x: 180, y: 526)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            dragging = true
                            let fraction = min(1, max(0, Double((value.location.x - 10) / 300)))
                            dragProgress = fraction
                            player.seek(to: fraction)
                        }
                        .onEnded { value in
                            let fraction = min(1, max(0, Double((value.location.x - 10) / 300)))
                            player.seek(to: fraction)
                            dragging = false
                            dragProgress = nil
                        }
                )

            hitButton(width: 96, height: 96, x: 180, y: 652) { player.toggle() }
            hitButton(width: 64, height: 64, x: 72, y: 652) { player.previous() }
            hitButton(width: 64, height: 64, x: 288, y: 652) { player.next() }
            hitButton(width: 56, height: 56, x: 302, y: 756) { importing = true }
            hitButton(width: 30, height: 30, x: 312, y: 452) { showingLibrary = true }
            hitButton(width: 42, height: 42, x: 32, y: 68) { showingLibrary = true }
            hitButton(width: 42, height: 42, x: 328, y: 68) { showingOptions = true }

            // Four existing lower dots are functional playback bookmarks.
            ForEach(0..<4, id: \.self) { index in
                hitButton(width: 34, height: 48,
                          x: CGFloat(70 + 51 * index), y: 756) {
                    player.seek(to: Double(index) / 3)
                }
            }
        }
        .frame(width: 360, height: 800)
    }

    private func hitButton(
        width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Rectangle()
                .fill(Color.black.opacity(0.001))
                .frame(width: width, height: height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
    }
}
