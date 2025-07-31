import Foundation

// From https://medium.com/@jules2689/secrets-management-in-ios-applications-52795c254ec1

class Secrets {

    private var secrets: [String: Any?]? = nil

    private struct SecretKeys {
        static let TBAAPIKey = "tba_api_key"
    }

    var tbaAPIKey: String {
        guard let secrets = secrets else {
            return ""
        }
        return secrets[SecretKeys.TBAAPIKey] as! String
    }

    init(secrets: String = "Secrets", in bundle: Bundle = Bundle.main) {
        if let path = bundle.path(forResource: secrets, ofType: "plist") {
            self.secrets = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject>
            print("Secrets.plist path:", path as Any)

        }
        
    }

}
