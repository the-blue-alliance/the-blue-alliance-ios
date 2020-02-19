import Combine
import TBAData
import SwiftUI

struct RobotLabel: View {

    private let colors = [
        "red": [Color.zebraRed1, Color.zebraRed2, Color.zebraRed3],
        "blue": [Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3]
    ]

    let team: MatchZebraTeam
    let index: Int

    /*
    var color: Color {
        let colors = self.colors[alliance.allianceKey] ?? self.colors["red"]
        guard let teamIndex = alliance.teams.firstIndex(of: team) else {
            return .random
        }
        return colors?[teamIndex] ?? .random
    }
    */

    var body: some View {
        VStack {
            Image(systemName: "\(index + 1).circle")
                .scaledToFit()
            Text(String(team.team.teamNumber))
        }
        .foregroundColor(.white)
    }

}

struct Robot: View {

    let team: MatchZebraTeam
    let index: Int
    let color: Color

    // TODO: If we're on a phone, show the digits/table
    // If we're on an iPad, show the numbers

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(self.color)
                Image(systemName: "\(self.index + 1).circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white)
            }
        }
    }

}

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

    private let timePublisher = PassthroughSubject<Double, Never>()

    private var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: (1.0/60.0), repeats: true) { timer in
            guard self.playing else {
                return
            }
            self.timePublisher.send(timer.timeInterval)
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
