import Foundation

struct MyTBAFavoritesRequest: Codable {
    var favorites: [MyTBAFavorite]
}

struct MyTBAFavoritesResponse: MyTBAResponse, Codable {
    var favorites: [MyTBAFavorite]?
}

public struct MyTBAFavorite: MyTBAModel, Equatable, Codable {

    public init(modelKey: String, modelType: MyTBAModelType) {
        self.modelKey = modelKey
        self.modelType = modelType
    }
    
    public static var arrayKey: String {
        return "favorites"
    }

    public var modelKey: String
    public var modelType: MyTBAModelType

    public static var fetch: (MyTBA) -> (@escaping ([MyTBAModel]?, Error?) -> Void) -> MyTBAOperation = MyTBA.fetchFavorites
}

extension MyTBA {

    public func fetchFavorites(_ completion: @escaping (_ favorites: [MyTBAFavorite]?, _ error: Error?) -> Void) -> MyTBAOperation {
        let method = "\(MyTBAFavorite.arrayKey)/list"

        return callApi(method: method, completion: { (favoritesResponse: MyTBAFavoritesResponse?, error) in
            completion(favoritesResponse?.favorites, error)
        })
    }

}
