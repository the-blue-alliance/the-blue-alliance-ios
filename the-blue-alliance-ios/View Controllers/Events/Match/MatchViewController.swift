import CoreData
import Foundation
import UIKit

class MatchContainerViewController: ContainerViewController {

    private let match: Match
    private let team: Team?

    // MARK: Init

    init(match: Match, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.match = match
        self.team = team

        let infoViewController = MatchInfoViewController(match: match, team: team, persistentContainer: persistentContainer)

        // Only show match breakdown if year is 2015 or onward
        var breakdownViewController: MatchBreakdownViewController?
        var titles: [String]  = ["Info"]
        if Int(match.event!.year) >= 2015 {
            titles.append("Breakdown")
            breakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer)
        }

        super.init(viewControllers: [infoViewController, breakdownViewController].compactMap({ $0 }) as! [ContainableViewController],
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        navigationTitle = "\(match.friendlyMatchName())"
        navigationSubtitle = "@ \(match.event!.friendlyNameWithYear)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
