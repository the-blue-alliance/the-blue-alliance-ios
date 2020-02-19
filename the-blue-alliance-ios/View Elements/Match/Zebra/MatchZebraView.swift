import Combine
import TBAData
import SwiftUI

struct FieldSize {
    static let width: CGFloat = 54.0
    static let height: CGFloat = 27.0
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

struct MatchZebraView: View {

    private let colors = [
        Color.zebraRed1, Color.zebraRed2, Color.zebraRed3,
        Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3
    ]

    @ObservedObject var match: Match
    // TODO: Pass `year`

    @State private var playing: Bool = false

    @State private var time: Double = 0.0
    private let timePublisher = PassthroughSubject<Double, Never>()

    private var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: (1.0/60.0), repeats: true) { _ in
            guard self.playing else {
                return
            }
            self.timePublisher.send(self.time)
            print("Publishing")
        }
    }

    var body: some View {
        VStack {
            ZStack {
                Image("2019_field")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                match.zebra.map {
                    ZebraView(
                        times: $0.times,
                        teams: $0.teams,
                        colors: colors,
                        timePublisher: timePublisher
                    )
                    .clipped()
                }
            }
            ZebraToolbar(
                playing: $playing
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
