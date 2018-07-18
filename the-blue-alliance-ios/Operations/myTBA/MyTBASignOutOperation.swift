import Foundation

class MyTBASignOutOperation: TBAOperation {

    var myTBA: MyTBA
    var pushToken: String

    init(myTBA: MyTBA, pushToken: String) {
        self.myTBA = myTBA
        self.pushToken = pushToken

        super.init()
    }

    override func execute() {
        myTBA.unregister(pushToken) { (error) in
            if let error = error {
                self.completionError = error
            }
            self.finish()
        }
    }

}
