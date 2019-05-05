import CoreData
import Foundation
import React
import TBAKit
import UIKit

class MatchBreakdownViewController: TBAReactNativeViewController, Observable {

    private let match: Match

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(match: Match, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match

        super.init(moduleName: "MatchBreakdown\(match.year)", persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

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

        return ["redTeams": match.redAllianceTeamNumbers,
                "redBreakdown": redBreakdown,
                "blueTeams": match.blueAllianceTeamNumbers,
                "blueBreakdown": blueBreakdown,
                "compLevel": match.compLevelString!]
    }

}

extension MatchBreakdownViewController: Refreshable {

    var refreshKey: String? {
        return match.key
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return match.breakdown == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchMatch(key: match.key!, { (result) in
            do {
                let match = try result.get()
                let context = self.persistentContainer.newBackgroundContext()
                context.performChangesAndWait({
                    if let match = match {
                        // TODO: Match can never be deleted
                        if let event = self.match.event {
                            let event = context.object(with: event.objectID) as! Event
                            event.insert(match)
                        } else {
                            Match.insert(match, in: context)
                        }
                    }
                }, saved: {
                    self.markTBARefreshSuccessful(self.tbaKit, request: request!)
                })
            } catch {
                // Pass
            }
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension MatchBreakdownViewController: Stateful {

    var noDataText: String {
        return "No breakdown for match"
    }

}
