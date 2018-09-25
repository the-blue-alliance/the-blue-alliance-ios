import CoreData
import Foundation
import UIKit

class MatchViewController: ContainerViewController {

    let match: Match
    let team: Team?

    private var infoViewController: MatchInfoViewController?
    private var breakdownViewController: MatchBreakdownViewController?

    override var viewControllers: [Refreshable & Stateful] {
        return [infoViewController, breakdownViewController].compactMap({ $0 })
    }

    // MARK: Init

    init(match: Match, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.match = match
        self.team = team

        // Only show match breakdown if year is 2015 or onward
        var titles: [String]  = ["Info"]
        if Int(match.event!.year) >= 2015 {
            titles.append("Breakdown")
        }

        super.init(segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        infoViewController = MatchInfoViewController(match: match, team: team, persistentContainer: persistentContainer)
        breakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer)
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
