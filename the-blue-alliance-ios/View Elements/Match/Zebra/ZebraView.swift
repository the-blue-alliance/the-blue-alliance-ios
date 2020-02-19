import Combine
import SwiftUI
import TBAData

struct ZebraView: View {

    let times: [Double]
    let teams: [MatchZebraTeam]
    let colors: [Color]
    let timerPublisher: PassthroughSubject<Double, Never>

    @State private var time: Double = 0
    @State private var initialPosition: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                ZebraRobot(team: self.teams[teamIndex], index: teamIndex, color: self.colors[teamIndex])
                    .frame(width: self.robotSize(geometry: geometry), height: self.robotSize(geometry: geometry))
                    .position(self.position(team: self.teams[teamIndex], geometry: geometry))
            }
        }
    }

    private func position(team: MatchZebraTeam, geometry: GeometryProxy) -> CGPoint {
        if initialPosition {
            return normalizedInitialPosition(team: team, geometry: geometry)
        }
        return interpolatedPosition(team: team, geometry: geometry)
    }

    private func normalizedInitialPosition(team: MatchZebraTeam, geometry: GeometryProxy) -> CGPoint {
        let position = team.firstPosition ?? .zero
        return normalizePoint(point: position, geometry: geometry)
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

        return normalizePoint(point: CGPoint(x: floorX + deltaX, y: floorY + deltaY), geometry: geometry)
    }

    private func normalizePoint(point: CGPoint, geometry: GeometryProxy) -> CGPoint {
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - point.y
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: point.x * scale, y: y * scale)
    }

    private func robotSize(geometry: GeometryProxy) -> CGFloat {
        // Robots should be a 1.3-radius circle with a 0.2 stroke
        let scale = geometry.size.width / FieldSize.width
        return scale * RobotSize.total
    }

}
