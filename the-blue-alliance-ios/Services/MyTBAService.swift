import FirebaseAuth
import Foundation
import MyTBAKit
import TBAUtils

// Note: Not *really* a myTBA service. Really just a glorified token refresher, until someone comes up with a better design
// to refresh tokens at the proper time before making requests to myTBA. Zach can probably figure it out, but he's very tired,
// and has a lot of other things to get done. So instead he built a glorified token refresher.
// Once we move to supporting Sign In with Apple we should move this in to the auth delegate thing that got built.
class MyTBAService {

    private let myTBA: MyTBA
    internal var retryService: RetryService
    private let errorRecorder: ErrorRecorder

    private var user: User?

    init(myTBA: MyTBA, retryService: RetryService, errorRecorder: ErrorRecorder) {
        self.myTBA = myTBA
        self.retryService = retryService
        self.errorRecorder = errorRecorder

        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.user = user
            self?.retry()
        }
    }

}

extension MyTBAService: Retryable {

    var retryInterval: TimeInterval {
        return 60
    }

    func retry() {
        if let user = user {
            user.getIDToken() { [weak self] (token, error) in
                if let error = error {
                    self?.errorRecorder.recordError(error)
                } else {
                    self?.myTBA.authToken = token
                }
            }
        } else {
            myTBA.authToken = nil
        }
    }

}
