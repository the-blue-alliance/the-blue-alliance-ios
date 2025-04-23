import Foundation
import TBAAPI
import TBAModels

class DistrictEventsViewController: SimpleEventsViewController {

    override class var firstEventKeyPathComparator: KeyPathComparator<Event> {
        return KeyPathComparator(\.weekString)
    }

    override class var sectionKey: (Event) -> String {
        return \.weekString
    }

    private let district: District

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override func performRefresh() async throws {
        events = try await api.getDistrictEvents(districtKey: district.key)
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No events for district"
    }

}
