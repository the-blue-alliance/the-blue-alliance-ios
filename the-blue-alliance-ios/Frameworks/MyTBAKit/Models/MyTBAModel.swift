import Foundation

// https://github.com/the-blue-alliance/the-blue-alliance/blob/364d6da2f3fc464deef5ba580ea37b6cd2816c4a/consts/model_type.py
enum MyTBAModelType: Int, Codable {
    case event
    case team
    case match
}

protocol MyTBAResponse: Codable {}

// Models for Favorite/Subscription
protocol MyTBAModel: Codable {

    static var arrayKey: String { get }

    var modelKey: String { get set }
    var modelType: MyTBAModelType { get set }

    static var fetch: (MyTBA) -> (@escaping ([MyTBAModel]?, Error?) -> Void) -> URLSessionDataTask { get }
}
