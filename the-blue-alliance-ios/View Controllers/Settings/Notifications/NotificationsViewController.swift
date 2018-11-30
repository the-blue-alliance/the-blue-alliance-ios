import CoreData
import Foundation
import FirebaseMessaging
import UIKit
import UserNotifications

private enum NotificationRow: Int {
    case device
    case firebase
    case myTBA
    case test
    case max
}

enum NotificationStatus: Int {
    case unknown
    case loading
    case invalid
    case valid
}

class NotificationsViewController: TBATableViewController {

    private let messaging: Messaging
    private let myTBA: MyTBA
    private let pushService: PushService

    private let deviceCell: NotificationStatusTableViewCell
    private var deviceAuthorization: UNAuthorizationStatus?

    private let firebaseCell: NotificationStatusTableViewCell

    private let myTBACell: NotificationStatusTableViewCell
    private var myTBAError: Error?

    private let pingCell: NotificationStatusTableViewCell
    lazy var cells = [deviceCell, firebaseCell, myTBACell, pingCell]

    init(messaging: Messaging, myTBA: MyTBA, pushService: PushService, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.messaging = messaging
        self.myTBA = myTBA
        self.pushService = pushService

        deviceCell = NotificationsViewController.cell("Device Settings")
        firebaseCell = NotificationsViewController.cell("Firebase Status")
        myTBACell = NotificationsViewController.cell("myTBA Registration")
        pingCell = NotificationsViewController.cell("Test Notification")

        super.init(style: .grouped, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        title = "Troubleshoot Notifications"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kick-off the first stage in our checks
        checkDeviceAuthorization()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationRow.max.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }

    // MARK: - Private Methods

    private static func cell(_ title: String) -> NotificationStatusTableViewCell {
        let cell = NotificationStatusTableViewCell.nib!.instantiate(withOwner: self, options: nil).first as! NotificationStatusTableViewCell
        cell.viewModel = NotificationStatusCellViewModel(title: title)
        return cell
    }

    private func updateCell(_ cell: NotificationStatusTableViewCell, status: NotificationStatus) {
        DispatchQueue.main.async {
            cell.viewModel = NotificationStatusCellViewModel(title: cell.viewModel!.title, notificationStatus: status)
        }
    }

    private func checkDeviceAuthorization() {
        updateCell(deviceCell, status: .loading)

        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            self.deviceAuthorization = settings.authorizationStatus

            let status: NotificationStatus = {
                switch settings.authorizationStatus {
                case .authorized:
                    return .valid
                case .notDetermined:
                    return .invalid
                case .denied:
                    return .invalid
                case .provisional:
                    return .valid
                }
            }()
            self.updateCell(self.deviceCell, status: status)
            self.checkFirebaseConfiguration()
        }
    }

    private func checkFirebaseConfiguration() {
        updateCell(firebaseCell, status: .loading)

        let status: NotificationStatus = {
            if messaging.fcmToken == nil {
                return .invalid
            } else {
                return .valid
            }
        }()
        updateCell(firebaseCell, status: status)
        checkMyTBARegistration()
    }

    private func checkMyTBARegistration() {
        updateCell(myTBACell, status: .loading)
        guard let fcmToken = messaging.fcmToken else {
            updateCell(myTBACell, status: .invalid)
            return
        }
        guard myTBA.authToken != nil else {
            updateCell(myTBACell, status: .invalid)
            return
        }
        myTBA.register(fcmToken) { (error) in
            self.myTBAError = error

            if error == nil {
                self.updateCell(self.myTBACell, status: .valid)
            } else {
                self.updateCell(self.myTBACell, status: .invalid)
            }
            self.sendPing()
        }
    }

    func sendPing() {
        // TODO: Find some way to send this device a ping from upstream
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let fcmToken = messaging.fcmToken {
            return "FCM Token: \(fcmToken)"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = cells[indexPath.row]
        if cell == deviceCell, let deviceAuthorization = deviceAuthorization {
            if deviceAuthorization == .denied {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else if deviceAuthorization == .notDetermined {
                PushService.requestAuthorizationForNotifications(nil)
            }
        } else if cell == firebaseCell {
            showError("No token from Firebase - try relaunching the app")
        } else if cell == myTBACell, let myTBAError = myTBAError {
            showError("Error registering with myTBA - \(myTBAError.localizedDescription)")
        } else if cell == pingCell {
            showError("Error sending test notification - something is wrong upstream")
        }
    }

    private func showError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
