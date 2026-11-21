import SwiftUI
import UniformTypeIdentifiers

@main
struct PlayerApp: App {
    var body: some Scene {
        WindowGroup {
            OriginalPlayerScreen()
        }
    }
}

struct OriginalPlayerScreen: View {
    @StateObject private var player = PlayerEngine()
    @State private var importing = false
    @State private var showingLibrary = false
    @State private var showingOptions = false
    @State private var showingError = false
    @State private var errorText = ""
    private let clock = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 360, geometry.size.height / 800)
            ZStack {
                Color.white.ignoresSafeArea()
                QwelExportedView(
                    elapsed: player.timeLabel(player.elapsed),
                    total: player.timeLabel(player.duration),
                    progress: CGFloat(player.progress),
                    playing: player.isPlaying,
                    trackTitle: player.title,
                    artist: player.artist,
                    onSeek: { fraction in player.seek(to: fraction) },
                    onToggle: { player.toggle() },
                    onPrevious: { player.previous() },
                    onNext: { player.next() },
                    onImport: { importing = true },
                    onLibrary: { showingLibrary = true },
                    onOptions: { showingOptions = true },
                    onBookmark: { index in player.seek(to: Double(index) / 3) }
                )
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
        .onReceive(clock) { _ in player.refresh() }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(let urls):
                    do {
                        try player.importAudio(urls)
                    } catch {
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
                    Button {
                        showingLibrary = false
                        importing = true
                    } label: {
                        Label("Добавить музыку", systemImage: "plus.circle")
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
        .alert("Ошибка музыки", isPresented: $showingError) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text(errorText)
        }
    }
}
