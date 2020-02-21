import Combine
import Foundation
import SwiftUI

struct TrajectoryToolbar: View {

    @Binding var playbackSpeed: PlaybackSpeed
    @Binding var playing: Bool
    @Binding var timestamp: Double
    let timestampMax: Double

    var body: some View {
        HStack {
            // Restart, show paths
            Image(systemName: "eye.fill")

            // Pause/play
            Button(action: {
                withAnimation { self.playing.toggle() }
            }) {
                Image(systemName: playing ? "pause.fill" : "play.fill")
            }

            // Restart
            Button(action: {
                MatchZebraView.initialPosition.send()
                self.timestamp = 0.0
            }) {
                Image(systemName: "backward.end.alt.fill")
            }
            .disabled(timestamp == 0.0 && !playing)

            // Slow down
            Button(action: {
                guard let index = PlaybackSpeed.allCases.firstIndex(of: self.playbackSpeed) else {
                    return
                }
                let nextIndex = index - 1
                guard nextIndex >= 0 else {
                    return
                }
                self.playbackSpeed = PlaybackSpeed.allCases[nextIndex]
            }) {
                Image(systemName: "backward.fill")
            }
            .disabled(playbackSpeed == PlaybackSpeed.allCases.first)

            // Speed
            Text("\(playbackSpeed.rawValue)x")

            // Speed up
            Button(action: {
                guard let index = PlaybackSpeed.allCases.firstIndex(of: self.playbackSpeed) else {
                    return
                }
                let nextIndex = index + 1
                guard nextIndex < PlaybackSpeed.allCases.count else {
                    return
                }
                self.playbackSpeed = PlaybackSpeed.allCases[nextIndex]
            }) {
                Image(systemName: "forward.fill")
            }
            .disabled(playbackSpeed == PlaybackSpeed.allCases.last)

            Slider(value: $timestamp, in: 0.0...timestampMax, step: 0.1, onEditingChanged: { (changed) in
                // TODO: Our positions aren't updating properly... why
                self.playing = !changed
            })

            // Timestamp - in the 0:00 format
            Text("\(String(format: "%01.0f", (timestamp / 60).rounded(.down))):\(String(format: "%02.0f", timestamp.truncatingRemainder(dividingBy: 60)))")
                .frame(width: 44, height: nil, alignment: .center)
        }
    }

}
