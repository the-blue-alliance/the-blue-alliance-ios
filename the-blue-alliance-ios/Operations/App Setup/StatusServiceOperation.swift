import Foundation

class StatusServiceOperation: TBAOperation {

    var statusService: StatusService

    init(statusService: StatusService) {
        self.statusService = statusService

        super.init()
    }

    override func execute() {
        self.statusService.setupStatusObservers()
        self.statusService.fetchStatus { [weak self] _ in
            self?.finish()
        }
    }

}
