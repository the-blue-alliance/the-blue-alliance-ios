import UIKit

extension NotificationCenter {

    /// Runs `refresh` each time the app comes back to the foreground. This is the app-level
    /// notification, so a second window opening while the app is already up doesn't fire it.
    /// Keep the returned token for as long as the refresh should keep happening.
    func addForegroundObserver(
        _ refresh: @escaping @MainActor () async -> Void
    ) -> ObservationToken {
        addObserver(of: UIApplication.self, for: .willEnterForeground) { _ in
            Task { await refresh() }
        }
    }

}
