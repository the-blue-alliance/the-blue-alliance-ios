import Foundation

class MyTBASignOutOperation: TBAOperation {

    var myTBA: MyTBA
    var pushToken: String
    var unregisterTask: URLSessionDataTask?

    init(myTBA: MyTBA, pushToken: String) {
        self.myTBA = myTBA
        self.pushToken = pushToken

        super.init()
    }

    override func execute() {
        unregisterTask = myTBA.unregister(pushToken) { (error) in
            self.unregisterTask = nil
            if let error = error {
                self.completionError = error
            }
            self.finish()
        }
    }

}
