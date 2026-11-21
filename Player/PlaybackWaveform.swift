import SwiftUI

// A live version of the original Qwel waveform: same 300 x 32 layout,
// four-point burgundy stroke and pink unplayed portion.
struct PlaybackWaveform: View {
    let progress: CGFloat

    private let playedColor = Color(
        red: 0.5764705882352941,
        green: 0.23529411764705882,
        blue: 0.36470588235294116
    )
    private let unplayedColor = Color(
        red: 0.984313725490196,
        green: 0.8470588235294118,
        blue: 0.8862745098039215
    )

    var body: some View {
        let cursor = min(CGFloat(300), max(CGFloat(0), progress * 300))
        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: CGPoint(x: cursor, y: 16))
                path.addLine(to: CGPoint(x: 300, y: 16))
            }
            .stroke(unplayedColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 300, height: 32)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 16))
                let steps = Int(cursor / 2)
                if steps > 0 {
                    for i in 1...steps {
                        let x = CGFloat(i) * 2
                        let y = 16 + CGFloat(5.304) * CGFloat(sin(Double(x) * .pi / 12))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                let endY = 16 + CGFloat(5.304) * CGFloat(sin(Double(cursor) * .pi / 12))
                path.addLine(to: CGPoint(x: cursor, y: endY))
            }
            .stroke(playedColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 300, height: 32)

            RoundedRectangle(cornerRadius: 2)
                .fill(playedColor)
                .frame(width: 4, height: 32)
                .position(x: cursor, y: 16)
        }
        .frame(width: 300, height: 32)
        .accessibilityHidden(true)
    }
}
