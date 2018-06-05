import Foundation

enum MyTBAModelType: String, Codable {
    case event = "0"
    case team = "1"
    case match = "2"
}

protocol MyTBAResponse: Codable {}

// Models for Favorite/Subscription
protocol MyTBAModel: Codable {

    static var arrayKey: String { get }

    var modelKey: String { get set }
    var modelType: MyTBAModelType { get set }

    static var fetch: ((@escaping ([MyTBAModel]?, Error?) -> Void) -> URLSessionDataTask) { get }
}
