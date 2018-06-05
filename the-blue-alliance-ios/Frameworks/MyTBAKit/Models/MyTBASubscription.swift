import Foundation

// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/notification_type.py
enum NotificationType: String, Codable {

    case upcomingMatch = "upcoming_match"
    case matchScore = "match_score"
    case levelStarting = "starting_comp_level"
    case allianceSelection = "alliance_selection"
    case awards = "awards_posted"
    case mediaPosted = "media_posted"
    case districtPointsUpdated = "district_points_updated"
    case scheduleUpdated = "schedule_updated"
    case finalResults = "final_results"
    case ping = "ping"
    case broadcast = "broadcast"
    case matchVideo = "match_video"
    case eventMatchVideo = "event_match_video"

    case updateFavorites = "update_favorites"
    case updateSubscription = "update_subscriptions"

    case verification = "verification"
}

struct MyTBASubscriptionsResponse: MyTBAResponse, Codable {

    var subscriptions: [MyTBASubscription]

}

struct MyTBASubscription: MyTBAModel, Codable {

    static var arrayKey: String {
        return "subscriptions"
    }

    var modelKey: String
    var modelType: MyTBAModelType
    var notifications: [NotificationType]

    static var fetch: ((@escaping ([MyTBAModel]?, Error?) -> Void) -> URLSessionDataTask) = MyTBA.shared.fetchSubscriptions

}

extension MyTBA {

    func fetchSubscriptions(_ completion: @escaping (_ subscriptions: [MyTBASubscription]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let method = "\(MyTBASubscription.arrayKey)/list"

        return callApi(method: method, completion: { (favoritesResponse: MyTBASubscriptionsResponse?, error) in
            completion(favoritesResponse?.subscriptions, error)
        })
    }

    func updateSubscription(_ subscriptions: MyTBASubscription, completion: @escaping (_ subscription: MyTBASubscription?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return nil
    }

}
