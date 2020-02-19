import Foundation
import TBAData
import SwiftUI

struct ZebraRobot: View {

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
