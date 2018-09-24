import CoreData
import Foundation
import UIKit

class MatchViewController: ContainerViewController {

    let match: Match
    let team: Team?

    // MARK: Init

    init(match: Match, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.match = match
        self.team = team

        var viewControllers: [TBAViewController] = [MatchInfoViewController(match: match, team: team, persistentContainer: persistentContainer)]

        // Only show match breakdown if year is 2015 or onward
        if Int(match.event!.year) >= 2015 {
            let matchBreakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer)
            viewControllers.append(matchBreakdownViewController)
        }

        super.init(segmentedControlTitles: ["Info", "Breakdown"],
                   persistentContainer: persistentContainer)

        self.viewControllers = viewControllers
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "\(match.friendlyMatchName())"
        navigationDetailLabel.text = "@ \(match.event!.friendlyNameWithYear)"
    }

}
