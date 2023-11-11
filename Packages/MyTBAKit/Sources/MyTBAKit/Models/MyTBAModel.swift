import Foundation

// https://github.com/the-blue-alliance/the-blue-alliance/blob/364d6da2f3fc464deef5ba580ea37b6cd2816c4a/consts/model_type.py
public enum MyTBAModelType: Int, Codable {
    case event
    case team
    case match
    case eventTeam
    case district
    case districtTeam
    case award
    case media
}

public protocol MyTBAResponse: Codable {}

// TODO: Remove when we move to Result
public typealias MyTBABaseCompletionBlock = (MyTBABaseResponse?, Error?) -> ()

public struct MyTBABaseResponse: MyTBAResponse, Codable {
    public var code: Int
    public var message: String

    enum CodingKeys: String, CodingKey {
        case code
        case message
    }

    public var error: MyTBAError? {
        if code >= 400 {
            return MyTBAError.error(code, message)
        }
        return nil
    }
}

// Models for Favorite/Subscription
public protocol MyTBAModel: Codable {

    static var arrayKey: String { get }

    var modelKey: String { get set }
    var modelType: MyTBAModelType { get set }

    static var fetch: (MyTBA) -> (@escaping ([MyTBAModel]?, Error?) -> Void) -> MyTBAOperation { get }
}
