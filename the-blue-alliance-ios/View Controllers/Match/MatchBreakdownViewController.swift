import CoreData
import Crashlytics
import Foundation
import React
import TBAData
import TBAKit
import UIKit

class MatchBreakdownViewController: TBAReactNativeViewController, Observable {

    private let match: Match
    private var matchBreakdownUnsupported = false

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(match: Match, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match

        super.init(moduleName: "MatchBreakdown", persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        delegate = self

        contextObserver.observeObject(object: match, state: .updated) { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }

    // MARK: Interface Methods

    func styleInterface() {
        // Override our default background color to match the match breakdown background color
        view.backgroundColor = UIColor.colorWithRGB(rgbValue: 0xdddddd)
    }

}

extension MatchBreakdownViewController: TBAReactNativeViewControllerDelegate {

    func showUnsupportedView() {
        matchBreakdownUnsupported = true
        showNoDataView(disableRefreshing: true)
    }

    var appProperties: [String: Any]? {
        // TODO: Support all alliances
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/273
        guard var redBreakdown = match.breakdown?["red"] as? [String: Any] else {
            return nil
        }
        guard var blueBreakdown = match.breakdown?["blue"] as? [String: Any] else {
            return nil
        }

        // For 2015 - map `coopertition` and `coopertition_points` points in to each breakdown dictionary
        if let coopertition = match.breakdown?["coopertition"] as? String, let coopertitionPoints = match.breakdown?["coopertition_points"] as? Int {
            // Setting these individually, since I can't seem to do a 'for in' to modify the above maps
            redBreakdown["coopertition"] = coopertition
            redBreakdown["coopertition_points"] = coopertitionPoints

            blueBreakdown["coopertition"] = coopertition
            blueBreakdown["coopertition_points"] = coopertitionPoints
        }

        return ["year": match.year,
                "redTeams": match.redAllianceTeamNumbers,
                "redBreakdown": redBreakdown,
                "blueTeams": match.blueAllianceTeamNumbers,
                "blueBreakdown": blueBreakdown,
                "compLevel": match.compLevelString!]
    }

}

extension MatchBreakdownViewController: Refreshable {

    var refreshKey: String? {
        return match.getValue(\Match.key)
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return match.getValue(\Match.breakdown) == nil
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: match.key!, { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let match):
                    if let match = match {
                        if let event = self.match.getValue(\Match.event) {
                            let event = context.object(with: event.objectID) as! Event
                            event.insert(match)
                        } else {
                            Match.insert(match, in: context)
                        }
                    } else if !notModified {
                        // TODO: Delete match, move back up our hiearchy
                    }
                default:
                    break
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        })
        addRefreshOperations([operation])
    }

}

extension MatchBreakdownViewController: Stateful {

    var noDataText: String {
        if matchBreakdownUnsupported {
            return "\(match.year) Match Breakdown is not supported"
        }
        return "No breakdown for match"
    }

}
