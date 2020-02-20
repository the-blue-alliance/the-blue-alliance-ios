import Combine
import Foundation
import TBAData
import SwiftUI

// TODO: If we're on a phone, show the digits/table
// If we're on an iPad, show the numbers

struct Robot: View {

    let times: [Double]
    let team: MatchZebraTeam
    let index: Int
    let color: Color

    @State var position: CGPoint = .zero
    @State var fieldGeometry: GeometryProxy

    let timestampPublisher: PassthroughSubject<Double, Never>
    let initialPositionPublisher: PassthroughSubject<Bool, Never>

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
            .position(self.position)
            .animation(.linear)
            .onReceive(self.initialPositionPublisher, perform: { (initialPosition) in
                guard initialPosition else {
                    return
                }
                self.setInitialPosition()
            })
            .onReceive(self.timestampPublisher, perform: { (timestamp) in
                self.setTimestampPosition(timestamp: timestamp)
            })
            .onAppear {
                self.setInitialPosition()
            }
        }
    }

    private func setInitialPosition() {
        if let position = team.firstPosition {
            self.position = Robot.normalizePoint(position, geometry: fieldGeometry)
        } else {
            self.position = .zero
        }
    }

    private func setTimestampPosition(timestamp: Double) {
        // Get our interpolated position for our timestamp
        // Round our values up/down and to the nearest tenth
        let timestampFloor = floor(timestamp * 10.0) / 10.0
        let timestampCeiling = ceil(timestamp * 10.0) / 10.0

        // Find where our team is starting at and where our team is going to next in points
        guard let lastPositionIndex = times.firstIndex(of: timestampFloor),
            let lastPositionX = team.xs[lastPositionIndex],
            let lastPositionY = team.ys[lastPositionIndex] else {
                return
        }
        guard let nextPositionIndex = times.firstIndex(of: timestampCeiling),
            let nextPositionX = team.xs[nextPositionIndex],
            let nextPositionY = team.ys[nextPositionIndex] else {
                return
        }

        let slopeX = (nextPositionX - lastPositionX)
        let slopeY = (nextPositionY - lastPositionY)

        let deltaX = (timestamp - timestampFloor) * slopeX
        let deltaY = (timestamp - timestampFloor) * slopeY

        let x = CGFloat(lastPositionX + deltaX)
        let y = CGFloat(lastPositionY + deltaY)

        self.position = Robot.normalizePoint(CGPoint(x: x, y: y), geometry: fieldGeometry)
    }

    private static func normalizePoint(_ point: CGPoint, geometry: GeometryProxy) -> CGPoint {
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - point.y
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: point.x * scale, y: y * scale)
    }

}

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
