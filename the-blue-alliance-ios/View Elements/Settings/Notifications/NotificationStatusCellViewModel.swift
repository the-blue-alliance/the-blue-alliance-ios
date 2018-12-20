import Foundation

struct NotificationStatusCellViewModel {

    let title: String
    let notificationStatus: NotificationStatus

    init(title: String, notificationStatus: NotificationStatus = .unknown) {
        self.title = title
        self.notificationStatus = notificationStatus
    }

}
