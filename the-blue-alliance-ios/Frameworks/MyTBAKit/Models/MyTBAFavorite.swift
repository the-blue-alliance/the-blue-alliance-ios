import Foundation
import GTMSessionFetcher

struct MyTBAFavoritesRequest: Codable {
    
    var favorites: [MyTBAFavorite]
    
}

struct MyTBAFavoritesResponse: MyTBAResponse, Codable {
    
    var favorites: [MyTBAFavorite]
    
}

struct MyTBAFavorite: MyTBAModel, Codable {
    
    static var arrayKey: String {
        return "favorites"
    }

    var modelKey: String
    var modelType: MyTBAModelType
    
    static var fetch: ((@escaping ([MyTBAModel]?, Error?) -> ()) -> GTMSessionFetcher) = MyTBA.shared.fetchFavorites

}

extension MyTBA {

    func fetchFavorites(_ completion: @escaping (_ favorites: [MyTBAFavorite]?, _ error: Error?) -> ()) -> GTMSessionFetcher {
        let method = "\(MyTBAFavorite.arrayKey)/list"
        
        return callApi(method: method, completion: { (favoritesResponse: MyTBAFavoritesResponse?, error) in
            completion(favoritesResponse?.favorites, error)
        })
    }
    
    func updateFavorite(_ favorite: MyTBAFavorite, completion: @escaping (_ favorites: MyTBAFavorite?, _ error: Error?) -> ()) -> GTMSessionFetcher? {
        // Something in here
        return nil
    }

    
}
