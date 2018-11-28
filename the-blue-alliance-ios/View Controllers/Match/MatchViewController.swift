import CoreData
import Foundation
import UIKit

class MatchViewController: ContainerViewController {

    // MARK: Init

    init(match: Match, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        let infoViewController = MatchInfoViewController(match: match, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // Only show match breakdown if year is 2015 or onward
        var breakdownViewController: MatchBreakdownViewController?
        var titles: [String]  = ["Info"]
        if match.year >= 2015 {
            titles.append("Breakdown")
            breakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        }

        super.init(
            viewControllers: [infoViewController, breakdownViewController].compactMap({ $0 }) as! [ContainableViewController],
            navigationTitle: "\(match.friendlyName)",
            navigationSubtitle: "@ \(match.event?.friendlyNameWithYear ?? match.key!)", // TODO: Use EventKey
            segmentedControlTitles: titles,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
