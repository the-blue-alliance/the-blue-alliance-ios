import Combine
import TBAData
import SwiftUI

struct FieldSize {
    static let width: CGFloat = 54.0
    static let height: CGFloat = 27.0
    // pathTimeLength = 50
}

struct RobotSize {
    static let radius: CGFloat = 1.3
    static let stroke: CGFloat =  0.2

    static var strokePercentage: CGFloat {
        return stroke / (stroke + radius)
    }
    static var total: CGFloat {
        return (stroke + radius) * 2
    }
}

enum PlaybackSpeed: Int, CaseIterable {
    case one = 1
    case five = 5
    case ten = 10
}

struct MatchZebraView: View {

    public static let timestampSubject = PassthroughSubject<Double, Never>()
    public static let initialPositionSubject = PassthroughSubject<Bool, Never>()

    private let colors = [
        Color.zebraRed1, Color.zebraRed2, Color.zebraRed3,
        Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3
    ]

    @ObservedObject var match: Match

    @State var playing = false
    @State var playbackSpeed = PlaybackSpeed.five

    @State private var timestamp: Double = 0.0
    private var timer: Timer {
        // 60fps
        Timer.scheduledTimer(withTimeInterval: (1.0/60.0), repeats: true) { timer in
            guard self.playing else {
                return
            }
            self.timestamp += (timer.timeInterval * Double(self.playbackSpeed.rawValue))
            // Round our timestamp to repeat when we hit our last timestamp - default to 2:30
            self.timestamp = self.timestamp.truncatingRemainder(dividingBy: self.match.zebra?.times.last ?? 150.0)
            MatchZebraView.timestampPublisher.send(self.timestamp)
        }
    }

    var body: some View {
        VStack {
            ZStack {
                Image("2019_field")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                match.zebra.map {
                    TrajectoryView(
                        colors: colors,
                        teams: $0.teams,
                        times: $0.times
                    )
                    .clipped()
                }
            }
            TrajectoryToolbar(
                playbackSpeed: $playbackSpeed,
                playing: $playing,
                timestamp: $timestamp,
                timestampMax: match.zebra?.times.last ?? 150.0
            )
        }
        .onAppear(perform: {
            _ = self.timer
        })
    }

}

struct AllianceTable: View {

    let teams: [MatchZebraTeam]
    let colors: [Color]

    var body: some View {
        HStack(alignment: .center) {
            ForEach(0..<teams.count, id: \.self) { (teamIndex: Int) in
                Group {
                    RobotLabel(team: self.teams[teamIndex], index: teamIndex)
                }
                .background(self.colors[teamIndex])
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
    }

}
