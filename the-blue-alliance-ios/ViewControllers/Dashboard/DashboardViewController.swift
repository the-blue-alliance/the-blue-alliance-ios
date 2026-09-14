import Foundation
import TBAAPI
import UIKit

class DashboardViewController: TBATableViewController, Refreshable {

    init(dependencies: Dependencies) {
        super.init(style: .insetGrouped, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { true }

    var supportsRefreshing: Bool { false }

    func refresh() {
        noDataReload()
    }

    var noDataText: String? { "Nothing to show yet. Search for teams and events above." }

}
