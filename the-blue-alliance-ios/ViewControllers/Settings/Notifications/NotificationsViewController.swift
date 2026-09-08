import Foundation
import MyTBAKit
import UIKit
import UserNotifications
import TBAAuth

private enum NotificationRow: Int, CaseIterable {
    case registration
    case device
    case firebase
    case myTBA
    case ping
}

enum NotificationStatus {
    case unknown
    case loading
    case invalid(String)
    case valid

    var isValid: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }
}

class NotificationsViewController: TBATableViewController {

    private lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(showCopyFCMToken)
    )
    private var notificationTokenFooter: UIView?

    private var fetchingRemoteNotificationRegistrationStatus = false
    private var hasCheckedRemoteNotificationRegistration = false
    private var remoteNotificationRegistrationError: (any Error)?

    private var fetchingDeviceAuthorizationStatus = false
    private var deviceAuthorizationStatus: UNAuthorizationStatus?

    private var myTBARegisterTask: Task<Void, Never>?
    private var myTBARegisterResponse: MyTBABaseResponse?
    private var myTBARegisterError: (any Error)?

    private var myTBAPingTask: Task<Void, Never>?
    private var myTBAPingResponse: MyTBABaseResponse?
    private var myTBAPingError: (any Error)?

    private let fcmTokenProvider: any FCMTokenProvider
    private let pushService: any PushServiceProtocol

    init(
        fcmTokenProvider: any FCMTokenProvider,
        pushService: any PushServiceProtocol,
        dependencies: Dependencies
    ) {
        self.fcmTokenProvider = fcmTokenProvider
        self.pushService = pushService

        super.init(style: .grouped, dependencies: dependencies)

        title = "Troubleshoot Notifications"
        hidesBottomBarWhenPushed = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kick-off the stages in our checks
        checkRemoteNotificationRegistration()
        Task { await checkDeviceAuthorization() }
        checkMyTBARegistration()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        myTBARegisterTask?.cancel()
        myTBAPingTask?.cancel()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            NotificationStatusTableViewCell.nib!.instantiate(withOwner: self, options: nil).first
            as! NotificationStatusTableViewCell

        let row = NotificationRow(rawValue: indexPath.row)!
        let viewModel: NotificationStatusCellViewModel = {
            switch row {
            case .registration:
                if fetchingRemoteNotificationRegistrationStatus {
                    return NotificationStatusCellViewModel(
                        title: "Checking Remote Notification Registration...",
                        notificationStatus: .loading
                    )
                } else {
                    var status = NotificationStatus.unknown
                    if hasCheckedRemoteNotificationRegistration {
                        if let error = remoteNotificationRegistrationError {
                            status = NotificationStatus.invalid(error.localizedDescription)
                        } else {
                            status = NotificationStatus.valid
                        }
                    }
                    return NotificationStatusCellViewModel(
                        title: "Remote Notification Registration",
                        notificationStatus: status
                    )
                }
            case .device:
                if fetchingDeviceAuthorizationStatus {
                    return NotificationStatusCellViewModel(
                        title: "Checking Device Notification Settings...",
                        notificationStatus: .loading
                    )
                } else {
                    var status = NotificationStatus.unknown
                    if let deviceAuthorizationStatus = deviceAuthorizationStatus {
                        status = deviceAuthorizationNotificationStatus(
                            forAuthorizationStatus: deviceAuthorizationStatus
                        )
                    }
                    return NotificationStatusCellViewModel(
                        title: "Device Notification Settings",
                        notificationStatus: status
                    )
                }
            case .firebase:
                let status: NotificationStatus = {
                    if fcmTokenProvider.fcmToken == nil {
                        return .invalid("No FCM token from Firebase")
                    } else {
                        return .valid
                    }
                }()
                return NotificationStatusCellViewModel(
                    title: "Firebase Token",
                    notificationStatus: status
                )
            case .myTBA:
                if myTBARegisterTask == nil {
                    let status = self.myTBARegistrationNotificationStatus()
                    return NotificationStatusCellViewModel(
                        title: "myTBA Registration",
                        notificationStatus: status
                    )
                } else {
                    return NotificationStatusCellViewModel(
                        title: "Checking myTBA Registration...",
                        notificationStatus: .loading
                    )
                }
            case .ping:
                if myTBAPingTask == nil {
                    let status = self.myTBAPingNotificationStatus()
                    return NotificationStatusCellViewModel(
                        title: "Ping Device",
                        notificationStatus: status
                    )
                } else {
                    return NotificationStatusCellViewModel(
                        title: "Pinging Device...",
                        notificationStatus: .loading
                    )
                }
            }
        }()
        cell.viewModel = viewModel
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationRow.allCases.count
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat
    {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        if let fcmToken = fcmTokenProvider.fcmToken {
            return "FCM Token: \(fcmToken)"
        }
        return nil
    }

    override func tableView(
        _ tableView: UITableView,
        willDisplayFooterView view: UIView,
        forSection section: Int
    ) {
        if section == 0, !(view.gestureRecognizers?.contains(longPressGestureRecognizer) ?? false) {
            notificationTokenFooter = view
            view.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = NotificationRow(rawValue: indexPath.row)!
        switch row {
        case .registration:
            if let error = remoteNotificationRegistrationError {
                showErrorAlert(with: error.localizedDescription)
            } else {
                showErrorAlert(
                    with:
                        "Unknown error registering for remote notifications - try force quitting and re-launching the app."
                )
            }
        case .device:
            if deviceAuthorizationStatus == .denied {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else if deviceAuthorizationStatus == .notDetermined {
                Task {
                    // Granted, denied, or errored - the row re-reads the real status.
                    _ = try? await pushService.requestAuthorizationForNotifications()
                    await checkDeviceAuthorization()
                }
            } else {
                showErrorAlert(
                    with:
                        "Unable to resolve device settings - check push notification settings in Settings.app"
                )
            }
        case .firebase:
            showErrorAlert(
                with: "No FCM token from Firebase - try force quitting and re-launching the app."
            )
        case .myTBA:
            let status = myTBARegistrationNotificationStatus()
            switch status {
            case .invalid(let str):
                showErrorAlert(with: "Error registering with myTBA - \(str)")
            default:
                showErrorAlert(with: "Unknown error registering with myTBA")
            }
        case .ping:
            let status = myTBAPingNotificationStatus()
            switch status {
            case .invalid(let str):
                showErrorAlert(with: "Error pinging device - \(str)")
            default:
                showErrorAlert(with: "Unknown error pinging device")
            }
        }
    }

    // MARK: - State Machine methods

    // MARK: - Remote Notification Registration

    private func checkRemoteNotificationRegistration() {
        // Already fetching remote notification registration status
        guard fetchingRemoteNotificationRegistrationStatus == false else {
            return
        }

        fetchingRemoteNotificationRegistrationStatus = true
        pushService.registerForRemoteNotifications { [weak self] (error) in
            self?.fetchingRemoteNotificationRegistrationStatus = false
            self?.hasCheckedRemoteNotificationRegistration = true
            self?.remoteNotificationRegistrationError = error

            self?.tableView.reloadData()
        }
        tableView.reloadData()
    }

    // MARK: - Device Settings

    @objc private func applicationWillEnterForeground() {
        Task { await checkDeviceAuthorization() }
    }

    private func checkDeviceAuthorization() async {
        guard !fetchingDeviceAuthorizationStatus else {
            return
        }
        fetchingDeviceAuthorizationStatus = true
        tableView.reloadData()

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        fetchingDeviceAuthorizationStatus = false
        deviceAuthorizationStatus = settings.authorizationStatus
        sendPing()
        tableView.reloadData()
    }

    private func deviceAuthorizationNotificationStatus(
        forAuthorizationStatus status: UNAuthorizationStatus
    )
        -> NotificationStatus
    {
        return {
            switch status {
            case .authorized:
                return .valid
            case .notDetermined:
                return .invalid("Have not yet asked for push notification permissions.")
            case .denied:
                return .invalid("Permission for push notifications was denied.")
            case .provisional:
                return .valid
            case .ephemeral:
                return .valid
            @unknown default:
                return .invalid("Unknown permissions error.")
            }
        }()
    }

    // MARK: - myTBA Registration

    private func checkMyTBARegistration() {
        // Already checking myTBA registration
        guard myTBARegisterTask == nil else {
            return
        }

        guard dependencies.authService.isSignedIn else {
            return
        }

        myTBARegisterTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.myTBA.register()
                self.myTBARegisterResponse = response
                self.myTBARegisterError = nil
            } catch {
                self.myTBARegisterResponse = nil
                self.myTBARegisterError = error
            }
            self.myTBARegisterTask = nil
            self.sendPing()
            self.tableView.reloadData()
        }

        tableView.reloadData()
    }

    private func myTBARegistrationNotificationStatus() -> NotificationStatus {
        if !dependencies.authService.isSignedIn {
            return .invalid("Not signed in to myTBA. Sign in under the myTBA tab.")
        } else if fcmTokenProvider.fcmToken == nil {
            return .invalid("No FCM token from Firebase.")
        } else if let myTBARegisterError = myTBARegisterError {
            return .invalid(myTBARegisterError.localizedDescription)
        } else if myTBARegisterResponse != nil {
            return .valid
        } else {
            return .unknown
        }
    }

    // MARK: - Ping

    func sendPing() {
        // We wouldn't get the ping, since our device isn't authorized to get push notifications
        let deviceAuthorizationStatusValid: Bool = {
            if let deviceAuthorizationStatus = self.deviceAuthorizationStatus {
                return self.deviceAuthorizationNotificationStatus(
                    forAuthorizationStatus: deviceAuthorizationStatus
                )
                .isValid
            }
            return false
        }()
        guard deviceAuthorizationStatusValid else {
            return
        }

        // Not auth'd to myTBA - request would fail
        guard dependencies.authService.isSignedIn else {
            return
        }

        // We're not registered to myTBA, so we wouldn't see a ping
        guard self.myTBARegistrationNotificationStatus().isValid else {
            return
        }

        // Already pinging device
        guard myTBAPingTask == nil else {
            return
        }

        myTBAPingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.myTBA.ping()
                self.myTBAPingResponse = response
                self.myTBAPingError = nil
            } catch {
                self.myTBAPingResponse = nil
                self.myTBAPingError = error
            }
            self.myTBAPingTask = nil
            self.tableView.reloadData()
        }

        tableView.reloadData()
    }

    private func myTBAPingNotificationStatus() -> NotificationStatus {
        if !dependencies.authService.isSignedIn {
            return .unknown
        } else if fcmTokenProvider.fcmToken == nil {
            return .unknown
        } else if let myTBAPingError = myTBAPingError {
            return .invalid(myTBAPingError.localizedDescription)
        } else if myTBAPingResponse != nil {
            return .valid
        } else {
            return .unknown
        }
    }

    // MARK: - UI Methods

    @objc func showCopyFCMToken() {
        guard let fcmToken = fcmTokenProvider.fcmToken else {
            return
        }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(title: "Copy Token", style: .default) { _ in
                self.copyFCMTokenToPasteboard(fcmToken)
            }
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let notificationTokenFooter = notificationTokenFooter {
            actionSheet.popoverPresentationController?.sourceView = notificationTokenFooter
        }

        present(actionSheet, animated: true, completion: nil)
    }

    private func copyFCMTokenToPasteboard(_ fcmToken: String) {
        UIPasteboard.general.string = fcmToken
    }

}
