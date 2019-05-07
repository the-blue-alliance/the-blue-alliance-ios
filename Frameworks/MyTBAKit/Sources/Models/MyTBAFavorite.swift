import Foundation

public struct MyTBAFavoritesRequest: Codable {
    var favorites: [MyTBAFavorite]
}

public struct MyTBAFavoritesResponse: MyTBAResponse, Codable {
    var favorites: [MyTBAFavorite]?
}

public struct MyTBAFavorite: MyTBAModel, Equatable, Codable {

    public static var arrayKey: String {
        return "favorites"
    }

    public var modelKey: String
    public var modelType: MyTBAModelType

    public init(modelKey: String, modelType: MyTBAModelType) {
        self.modelKey = modelKey
        self.modelType = modelType
    }

    public static var fetch: (MyTBA) -> (@escaping ([MyTBAModel]?, Error?) -> Void) -> URLSessionDataTask = MyTBA.fetchFavorites
}

extension MyTBA {

    @discardableResult
    public func fetchFavorites(_ completion: @escaping (_ favorites: [MyTBAFavorite]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let method = "\(MyTBAFavorite.arrayKey)/list"

        return callApi(method: method, completion: { (favoritesResponse: MyTBAFavoritesResponse?, error) in
            completion(favoritesResponse?.favorites, error)
        })
    }

}
