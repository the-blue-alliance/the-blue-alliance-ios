import Foundation

extension DistrictRanking {

    // TODO: Audit the uses of this to see if we can have empty events when using this
    public var sortedEventPoints: [DistrictEventPoints] {
        let eventPointsSet = getValue(\DistrictRanking.eventPoints)
        return (eventPointsSet.allObjects as? [DistrictEventPoints])?.sorted(by: { (lhs, rhs) -> Bool in
            let lhsEvent = lhs.getValue(\DistrictEventPoints.event)
            guard let lhsStartDate = lhsEvent.getValue(\Event.startDate) else {
                return false
            }
            let rhsEvent = rhs.getValue(\DistrictEventPoints.event)
            guard let rhsStartDate = rhsEvent.getValue(\Event.startDate) else {
                return false
            }
            return rhsStartDate > lhsStartDate
        }) ?? []
    }

}

extension DistrictRanking: Managed {

    public var isOrphaned: Bool {
        return district == nil
    }

}
