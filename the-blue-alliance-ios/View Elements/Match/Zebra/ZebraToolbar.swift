import Foundation
import SwiftUI

struct ZebraToolbar: View {

    @State var playing = false

    var body: some View {
        HStack {
            Image(systemName: "eye.fill")

            Button(action: {
                self.playing = !self.playing
            }) {
                playing ? Image(systemName: "play.fill") : Image(systemName: "pause.fill")
            }
            .frame(width: 44, height: 44, alignment: .center)
            .background(Color.gray)

            Image(systemName: "backward.end.alt.fill")
            Image(systemName: "backward.fill")
            Text("5x")
            Image(systemName: "forward.fill")
            // Slider(value: $time, in: 0.0...Double($0.times.count), step: 1.0)
            Text("0:00")
        }
    }

}
