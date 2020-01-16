import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

class MatchBreakdownViewController: TBAViewController, Observable {

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

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()

        contextObserver.observeObject(object: match, state: .updated) { _, _ in
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }

    // MARK: Interface Methods

    func styleInterface() {
        // Override our default background color to match the match breakdown background color
        // TODO: Figure out what we want here
    }

    override func reloadData() {
        // Pass
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
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: match.key, { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let match):
                    if let match = match {
                        Match.insert(match, in: context)
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
            return "\(match.event.year) Match Breakdown is not supported"
        }
        return "No breakdown for match"
    }

}
