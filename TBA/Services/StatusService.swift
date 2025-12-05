import AsyncAlgorithms
import Foundation
import Observation
import OpenAPIRuntime
import os
import TBAAPI

private let defaultStatus = Status(
    currentSeason: Calendar.current.year,
    maxSeason: Calendar.current.year,
    isDatafeedDown: false,
    downEvents: [],
    ios: Status.AppInfo(
        minAppVersion: -1,
        latestAppVersion: -1,
    ),
    android: Status.AppInfo(
        minAppVersion: -1,
        latestAppVersion: -1,
    ),
    maxTeamPage: -1,
)

@MainActor
@Observable
class StatusService {
    private(set) var status: Status {
        didSet {
            do {
                try userDefaults.setStatus(status: status)
            } catch {
                logger.error("StatusService failed to write status to UserDefaults: \(error)")
            }
        }
    }

    private let api: TBAAPI
    private let userDefaults: UserDefaults

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: StatusService.self),
    )

    init(api: TBAAPI, userDefaults: UserDefaults) {
        self.api = api
        self.userDefaults = userDefaults

        do {
            if let status = try userDefaults.getStatus() {
                self.status = status
                logger.debug("Using UserDefaults Status")
            } else {
                status = defaultStatus
                logger.debug("Using default Status")
            }
        } catch {
            logger.error("Error fetching Status from UserDefaults: \(error)")
            status = defaultStatus
        }

        // Kickoff an initial refresh
        // TODO: This likely should not live here - maybe we manage these
        // services in the AppDelegate level some other way...
        Task {
            try await refresh()
        }
    }

    // MARK: - Public Methods

    func refresh() async throws {
        async let refreshTask = api.getStatus()
        logger.debug("StatusService refresh started")
        do {
            let response = try await refreshTask
            try Task.checkCancellation()
            status = try response.ok.body.json
            logger.info("StatusService refresh successful")
        } catch {
            var wasCancelled = false
            if error is CancellationError {
                wasCancelled = true
            } else if let clientError = error as? ClientError {
                if clientError.underlyingError is CancellationError {
                    wasCancelled = true
                } else if let urlError = clientError.underlyingError as? URLError,
                          urlError.code == .cancelled
                {
                    wasCancelled = true
                }
            }
            if wasCancelled {
                logger.debug("StatusService refresh cancelled")
            } else {
                throw error
            }
        }
    }
}

// TODO: Write a wrapper to protect UserDefaults access
private extension UserDefaults {
    private static let kStatus = "kStatus"

    func getStatus() throws -> Status? {
        guard let encodedStatus = object(forKey: Self.kStatus) as? Data else {
            return nil
        }
        return try PropertyListDecoder().decode(Status.self, from: encodedStatus)
    }

    func setStatus(status: Status) throws {
        let encodedStatus = try PropertyListEncoder().encode(status)
        set(encodedStatus, forKey: Self.kStatus)
    }
}
