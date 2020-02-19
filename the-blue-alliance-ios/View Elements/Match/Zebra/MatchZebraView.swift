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

struct ZebraView: View {

    let teams: [MatchZebraTeam]
    let colors: [Color]

    @State var interval: Int = 0
    @State private var initialPosition: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                Robot(team: self.teams[teamIndex],
                      index: teamIndex,
                      color: self.colors[teamIndex])
                    .position(self.intervalPosition(team: self.teams[teamIndex],
                                                    geometry: geometry))
                    .frame(width: self.robotSize(geometry: geometry),
                           height: self.robotSize(geometry: geometry))
            }
        }
    }

    private func intervalPosition(team: MatchZebraTeam, geometry: GeometryProxy) -> CGPoint {
        // TODO: Allow this to be nil to keep existing position
        let position: CGPoint = {
            if initialPosition {
                return team.firstPosition ?? .zero
            } else {
                guard let x = team.xs[interval], let y = team.ys[interval] else {
                    return .zero
                }
                let p = CGPoint(x: x, y: y)
                print("New position: \(p)")
                return p
            }
        }()
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - position.y
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: position.x * scale, y: y * scale)
    }

    private func robotSize(geometry: GeometryProxy) -> CGFloat {
        // Robots should be a 1.3-radius circle with a 0.2 stroke
        let scale = geometry.size.width / FieldSize.width
        return scale * RobotSize.total
    }

}

struct MatchZebraView: View {

    private let colors = [
        Color.zebraRed1, Color.zebraRed2, Color.zebraRed3,
        Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3
    ]

    @ObservedObject var match: Match

    @State private var playing: Bool = false

    @State private var interval: Int = 0
    private var timer: Timer {
        // TODO: We could update this at 60fps and round down
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard self.playing else {
                return
            }
            guard let times = self.match.zebra?.times else {
                return
            }
            self.interval = (self.interval + 1) % times.count
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
                        teams: $0.teams,
                        colors: colors
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
