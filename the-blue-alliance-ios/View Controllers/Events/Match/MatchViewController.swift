import CoreData
import Foundation
import UIKit

class MatchContainerViewController: ContainerViewController {

    // MARK: Init

    init(match: Match, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer) {
        let infoViewController = MatchInfoViewController(match: match, teamKey: teamKey, persistentContainer: persistentContainer)

        // Only show match breakdown if year is 2015 or onward
        var breakdownViewController: MatchBreakdownViewController?
        var titles: [String]  = ["Info"]
        if match.event!.year!.intValue >= 2015 {
            titles.append("Breakdown")
            breakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer)
        }

        super.init(viewControllers: [infoViewController, breakdownViewController].compactMap({ $0 }) as! [ContainableViewController],
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        navigationTitle = "\(match.friendlyName)"
        navigationSubtitle = "@ \(match.event!.friendlyNameWithYear)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
