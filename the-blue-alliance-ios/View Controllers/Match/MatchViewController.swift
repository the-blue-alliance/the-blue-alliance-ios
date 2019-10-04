import CoreData
import Firebase
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class MatchViewController: MyTBAContainerViewController {

    private(set) var match: Match

    private(set) var infoViewController: MatchInfoViewController
    private(set) var breakdownViewController: MatchBreakdownViewController?

    private let statusService: StatusService
    private let urlOpener: URLOpener

    override var subscribableModel: MyTBASubscribable {
        return match
    }

    // MARK: Init

    init(match: Match, teamKey: TeamKey? = nil, statusService: StatusService, urlOpener: URLOpener, messaging: Messaging, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match
        self.statusService = statusService
        self.urlOpener = urlOpener
        infoViewController = MatchInfoViewController(match: match, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // Only show match breakdown if year is 2015 or onward
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
            messaging: messaging,
            myTBA: myTBA,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )
        
        infoViewController.matchSummaryDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("match", parameters: ["match": match.key!])
    }

}

extension MatchViewController: MatchSummaryViewDelegate {
    
    func teamPressed(teamNumber: Int) {
        guard let event = match.event else { return }
        
        // get team key that matches the target teamNumber
        guard let teamKey = match.teamKeys.first(where: { $0.teamNumber == "\(teamNumber)"}) else { return }
        
        let teamAtEventVC = TeamAtEventViewController(teamKey: teamKey, event: event, messaging: messaging, myTBA: myTBA, showDetailEvent: true, showDetailTeam: false, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(teamAtEventVC, animated: true)
    }
    
}
