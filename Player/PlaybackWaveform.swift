import SwiftUI

/// Vector waveform built from the exported 300 x 32 control, not a bitmap.
/// The waveform reveals itself on launch and gently moves while music plays.
struct PlaybackWaveform: View {
    let progress: CGFloat
    let playing: Bool
    let onSeek: (Double) -> Void

    @State private var reveal: CGFloat = 0

    private let played = Color(red: 0.5764705882, green: 0.2352941176, blue: 0.3647058824)
    private let waiting = Color(red: 0.9843137255, green: 0.8470588235, blue: 0.8862745098)
    private let width: CGFloat = 300

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !playing)) { timeline in
            let p = min(1, max(0, progress))
            let currentX = width * p
            let endX = width * reveal
            let phase = playing ? timeline.date.timeIntervalSinceReferenceDate * 5.0 : 0
            ZStack(alignment: .topLeading) {
                // Unplayed part is always visible, including before music starts.
                wave(phase: phase)
                    .trimmedPath(from: 0, to: reveal)
                    .stroke(waiting, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Played part has the same shape as the unplayed part.
                wave(phase: phase)
                    .trimmedPath(from: 0, to: min(reveal, p))
                    .stroke(played, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))

                // Playback position indicator; moves when the track advances or is scrubbed.
                RoundedRectangle(cornerRadius: 2)
                    .fill(played)
                    .frame(width: 4, height: 32)
                    .position(x: min(width - 2, max(2, currentX)), y: 22)
            }
            .frame(width: width, height: 44)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        onSeek(Double(min(1, max(0, value.location.x / width))))
                    }
                    .onEnded { value in
                        onSeek(Double(min(1, max(0, value.location.x / width))))
                    }
            )
        }
        .frame(width: width, height: 44)
        .onAppear {
            reveal = 0
            withAnimation(.easeOut(duration: 2.0)) {
                reveal = 1
            }
        }
        .accessibilityLabel("Прогресс воспроизведения")
        .accessibilityValue("\(Int(min(1,max(0,progress))*100)) процентов")
    }

    private func wave(phase: Double) -> Path {
        Path { path in
            let step: CGFloat = 2
            for i in 0...150 {
                let x = CGFloat(i) * step
                let y = 22 + CGFloat(5.3 * sin(Double(x) * .pi / 12.0 - phase))
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

private extension Path {
    func trimmedPath(from start: CGFloat, to end: CGFloat) -> Path {
        self.trimmedPath(from: start, to: end)
    }
}
