import Foundation
import SwiftUI

struct ZebraToolbar: View {

    @Binding var playing: Bool

    var body: some View {
        HStack {
            Image(systemName: "eye.fill")

            Button(action: {
                self.playing = !self.playing
            }) {
                playing ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
            }

            Image(systemName: "backward.end.alt.fill")
            Image(systemName: "backward.fill")
            Text("5x")
            Image(systemName: "forward.fill")
            // Slider(value: $time, in: 0.0...Double($0.times.count), step: 1.0)
            Text("0:00")
        }
    }

}
