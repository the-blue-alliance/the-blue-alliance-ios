import CoreData
import Crashlytics
import Foundation
import SpriteKit
import SwiftUI
import TBAData
import TBAKit
import UIKit

class MatchZebraViewController: TBAViewController {

    private let match: Match

    // MARK: - UI

    private lazy var zebraHostingController = UIHostingController(
        rootView: MatchZebraView(match: match)
    )

    // MARK: Init

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

        // Only show Zebra for suppoted years
        if [2019].contains(match.event.year) {
            styleInterface()
        } else {
            disableRefreshing()
            if let self = self as? Stateful & Refreshable {
                self.showNoDataView()
            }
        }
    }

    // MARK: Interface Methods

    func styleInterface() {
        scrollView.addSubview(zebraHostingController.view)
        zebraHostingController.view.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 8)
        zebraHostingController.view.autoPinEdge(.bottom, to: .bottom, of: scrollView, withOffset: -8)
        zebraHostingController.view.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        zebraHostingController.view.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)
        // TODO: This is broken but we should try to make it fit in the frame?
        // zebraHostingController.view.autoMatch(.height, to: .height, of: view, withOffset: 0.0, relation: .lessThanOrEqual)
    }

    override func reloadData() {
        // Pass
    }

}

extension MatchZebraViewController: Refreshable {

    var refreshKey: String? {
        return "\(match.key)_zebra"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return match.zebra == nil
    }

    @objc func refresh() {
        var zebraOperation: TBAKitOperation!
        zebraOperation = tbaKit.fetchMatchZebra(key: match.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let zebra):
                    if !notModified, let zebra = zebra {
                        let match = context.object(with: self.match.objectID) as! Match
                        match.insert(zebra)
                    }
                default:
                    break
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: zebraOperation!)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([zebraOperation])
    }

}
