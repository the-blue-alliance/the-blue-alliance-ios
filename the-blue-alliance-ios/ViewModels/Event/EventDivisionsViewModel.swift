import Foundation
import TBAAPI

nonisolated struct EventDivision: Hashable {
    let key: String
    let name: String
    let shortName: String

    init(event: Event) {
        key = event.key
        name = event.name
        shortName = event.safeShortName
    }

    init(key: String, name: String, shortName: String) {
        self.key = key
        self.name = name
        self.shortName = shortName
    }
}

/// The events reachable sideways from an event: a championship's own divisions,
/// or for a division, its siblings and the event its winners advance to.
nonisolated struct EventDivisionsViewModel: Hashable {

    let others: [EventDivision]
    let parent: EventDivision?

    var isEmpty: Bool { others.isEmpty && parent == nil }

    /// Titles the picker the way the web does. Only a division has a parent,
    /// so that alone distinguishes "the rest of them" from "this event's".
    var menuTitle: String? {
        guard !others.isEmpty else { return nil }
        return parent == nil ? "Event Divisions" : "Other Divisions"
    }

    init(others: [EventDivision] = [], parent: EventDivision? = nil) {
        self.others = others
        self.parent = parent
    }

    static func load(for event: Event, api: any TBAAPIProtocol) async -> EventDivisionsViewModel {
        var siblingKeys = event.divisionKeys
        var parentEvent: Event?

        // A division knows its parent but not its siblings, so the parent is
        // what holds the full list.
        if siblingKeys.isEmpty, let parentEventKey = event.parentEventKey {
            parentEvent = try? await api.event(key: parentEventKey)
            siblingKeys = parentEvent?.divisionKeys ?? []
        }

        // Task handles rather than a task group, see issue #996.
        let handles =
            siblingKeys
            .filter { $0 != event.key }
            .map { key in Task { try? await api.event(key: key) } }

        var others: [EventDivision] = []
        for handle in handles {
            guard let division = await handle.value else { continue }
            others.append(EventDivision(event: division))
        }

        return EventDivisionsViewModel(
            others: others,
            parent: parentEvent.map(EventDivision.init(event:))
        )
    }

}
