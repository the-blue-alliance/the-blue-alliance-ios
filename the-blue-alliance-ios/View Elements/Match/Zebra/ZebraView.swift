import Combine
import SwiftUI
import TBAData

// public let imagePublisher = PassthroughSubject<Image, Never>()

struct ZebraView: View {

    // TODO: We probably need times?
    let times: [Double]
    let teams: [MatchZebraTeam]
    let colors: [Color]
    let timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>

    @State private var time: Double = 0
    @State private var initialPosition: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                Robot(team: self.teams[teamIndex],
                      index: teamIndex,
                      color: self.colors[teamIndex])
                    .position(self.interpolatedPosition(team: self.teams[teamIndex],
                                                        geometry: geometry))
                    .frame(width: self.robotSize(geometry: geometry),
                           height: self.robotSize(geometry: geometry))
                    .onReceive(self.timerPublisher) { (time) in
                        print(time)
                        self.initialPosition = false
                        // self.time = time
                }
            }
        }
    }

    private func interpolatedPosition(team: MatchZebraTeam, geometry: GeometryProxy) -> CGPoint {
        let timeFloor = time.rounded(.down)
        let timeCeil = time.rounded(.up)

        // TODO: Make sure we just don't move
        guard let floorIndex = times.firstIndex(of: timeFloor), let ceilIndex = times.firstIndex(of: timeCeil) else {
            return .zero
        }
        let (floor, ceil) = ((team.xs[floorIndex], team.ys[floorIndex]), (team.xs[ceilIndex], team.ys[ceilIndex]))

        // TODO: Make sure we just don't move
        guard let floorX = floor.0, let floorY = floor.1, let ceilX = ceil.0, let ceilY = ceil.1 else {
            return .zero
        }

        let slopeX = ceilX - floorX
        let slopeY = ceilY - floorY

        let deltaX = (time - timeFloor) * slopeX
        let deltaY = (time - timeFloor) * slopeY

        let x = CGFloat(floorX + deltaX)
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - CGFloat(floorY + deltaY)
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: x * scale, y: y * scale)

        /*
        // TODO: Allow this to be nil to keep existing position
        let position: CGPoint = {
            if initialPosition {
                return team.firstPosition ?? .zero
            } else {
                guard let x = team.xs[interval], let y = team.ys[interval] else {
                    return .zero
                }
                return CGPoint(x: x, y: y)
            }
        }()
        */
    }

    private func robotSize(geometry: GeometryProxy) -> CGFloat {
        // Robots should be a 1.3-radius circle with a 0.2 stroke
        let scale = geometry.size.width / FieldSize.width
        return scale * RobotSize.total
    }

}
