import Foundation
import TBAAPI
import TBAModels

class DistrictEventsViewController: SimpleEventsViewController {

    private let district: District

    // TODO: We need a way to change how these get sorted across different views...

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override func performRefresh() async throws {
        self.events = try await api.getDistrictEvents(districtKey: district.key)
    }

    // MARK: - SimpleEventsViewControllerDataSourceConfiguration

    override var firstKeyPathComparator: KeyPathComparator<TBAModels.Event> {
        return KeyPathComparator(\.week)
    }

    override var groupingKeyForValue: (Event) -> String {
        return \.weekString
    }

}

extension DistrictEventsViewController: Stateful {
    var noDataText: String? {
        return "No events for district"
    }
}
