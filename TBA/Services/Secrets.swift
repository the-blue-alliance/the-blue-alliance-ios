import Foundation

// From https://medium.com/@jules2689/secrets-management-in-ios-applications-52795c254ec1

struct Secrets {

    private struct SecretKeys {
        static let TBAAPIKey = "tba_api_key"
    }

    private var secrets: [String: Any?]? = nil

    var tbaAPIKey: String {
        guard let secrets = secrets else {
            return ""
        }
        return secrets[SecretKeys.TBAAPIKey] as! String
    }

    init(secretsPlistName: String = "Secrets", in bundle: Bundle = Bundle.main) {
        if let path = bundle.path(forResource: secretsPlistName, ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject>
        }
    }

}
