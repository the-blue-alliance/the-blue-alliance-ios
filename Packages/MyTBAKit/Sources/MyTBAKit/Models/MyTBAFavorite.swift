import Foundation

struct MyTBAFavoritesRequest: Codable {
    var favorites: [MyTBAFavorite]
}

struct MyTBAFavoritesResponse: MyTBAResponse, Codable {
    var favorites: [MyTBAFavorite]?
}

public struct MyTBAFavorite: MyTBAModel, Equatable, Codable, Sendable {

    public init(modelKey: String, modelType: MyTBAModelType) {
        self.modelKey = modelKey
        self.modelType = modelType
    }

    public static var arrayKey: String {
        return "favorites"
    }

    public var modelKey: String
    public var modelType: MyTBAModelType
}

extension MyTBA {

    public func fetchFavorites() async throws -> [MyTBAFavorite] {
        let response: MyTBAFavoritesResponse = try await callApi(
            method: "\(MyTBAFavorite.arrayKey)/list"
        )
        return response.favorites ?? []
    }

}
