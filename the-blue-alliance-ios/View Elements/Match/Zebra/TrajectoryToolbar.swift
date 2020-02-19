import Foundation
import SwiftUI

struct TrajectoryToolbar: View {

    @Binding var playbackSpeed: PlaybackSpeed
    @Binding var playing: Bool
    @Binding var timestamp: Double

    var body: some View {
        HStack {
            // Restart, show paths
            Image(systemName: "eye.fill")

            // Pause/play
            Button(action: {
                self.playing = !self.playing
            }) {
                playing ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
            }

            // Restart
            Button(action: {
                // TODO: Disable if at start
                self.timestamp = 0.0
            }) {
                Image(systemName: "backward.end.alt.fill")
            }
            .disabled(timestamp == 0.0 && !playing)

            // Slow down
            Button(action: {
                self.playbackSpeed = PlaybackSpeed(rawValue: self.playbackSpeed.rawValue - 1) ?? PlaybackSpeed.allCases.first!
            }) {
                Image(systemName: "backward.fill")
            }
            .disabled(playbackSpeed == PlaybackSpeed.allCases.first)

            // Speed
            Text("\(playbackSpeed.rawValue)x")

            // Speed up
            Button(action: {
                self.playbackSpeed = PlaybackSpeed(rawValue: self.playbackSpeed.rawValue + 1) ?? PlaybackSpeed.allCases.last!
            }) {
                Image(systemName: "forward.fill")
            }
            .disabled(playbackSpeed == PlaybackSpeed.allCases.last)

            // Slider(value: $time, in: 0.0...Double($0.times.count), step: 1.0)

            // Timestamp - in the 0:00 format
            Text("\(String(format: "%01.0f", timestamp / 60)):\(String(format: "%02.0f", timestamp.truncatingRemainder(dividingBy: 60)))")
        }
    }

}
