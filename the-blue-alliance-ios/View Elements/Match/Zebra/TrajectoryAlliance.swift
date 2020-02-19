import Combine
import Foundation
import TBAData
import SwiftUI

struct TrajectoryView: View {

    let times: [Double]
    let teams: [MatchZebraTeam]
    let colors: [Color]

    let timestampPublisher: PassthroughSubject<Double, Never>
    let initialPositionPublisher: PassthroughSubject<Bool, Never>

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                Robot(times: self.times,
                      team: self.teams[teamIndex],
                      index: teamIndex,
                      color: self.colors[teamIndex],
                      fieldGeometry: geometry,
                      timestampPublisher: self.timestampPublisher,
                      initialPositionPublisher: self.initialPositionPublisher)
                    .frame(width: self.robotSize(geometry: geometry),
                           height: self.robotSize(geometry: geometry))
            }
        }
    }

    private func robotSize(geometry: GeometryProxy) -> CGFloat {
        // Robots should be a 1.3-radius circle with a 0.2 stroke
        let scale = geometry.size.width / FieldSize.width
        return scale * RobotSize.total
    }

}
