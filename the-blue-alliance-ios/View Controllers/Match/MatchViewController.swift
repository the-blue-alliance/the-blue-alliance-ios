import CoreData
import Firebase
import Foundation
import TBAKit
import UIKit

class MatchViewController: MyTBAContainerViewController {

    private(set) var match: Match

    private(set) var infoViewController: MatchInfoViewController
    private(set) var breakdownViewController: MatchBreakdownViewController?
    
    public var matchSummaryDelegate: MatchSummaryViewDelegate? {
        set {
            self.infoViewController.matchSummaryDelegate = newValue
        }
        get {
            return self.infoViewController.matchSummaryDelegate
        }
    }

    override var subscribableModel: MyTBASubscribable {
        return match
    }

    // MARK: Init

    init(match: Match, teamKey: TeamKey? = nil, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match

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
            myTBA: myTBA,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )
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
