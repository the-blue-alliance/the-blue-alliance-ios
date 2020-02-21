import Combine
import Foundation
import TBAData
import SwiftUI

struct TrajectoryView: View {

    let colors: [Color]
    let teams: [MatchZebraTeam]
    let times: [Double]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                TrajectoryRobot(color: self.colors[teamIndex],
                                fieldGeometry: geometry,
                                index: teamIndex,
                                team: self.teams[teamIndex],
                                times: self.times)
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
