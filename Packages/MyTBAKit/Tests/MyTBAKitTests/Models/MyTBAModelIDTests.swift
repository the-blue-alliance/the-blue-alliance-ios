import Testing

@testable import MyTBAKit

struct MyTBAModelIDTests {

    private let teamID = MyTBAModelID(modelType: .team, modelKey: "frc7332")

    @Test func favoriteIDIsItsKeyAndType() {
        #expect(MyTBAFavorite(modelKey: "frc7332", modelType: .team).id == teamID)
    }

    @Test func subscriptionIDIgnoresNotifications() {
        let matchScores = MyTBASubscription(
            modelKey: "frc7332",
            modelType: .team,
            notifications: [.matchScore]
        )
        let awards = MyTBASubscription(
            modelKey: "frc7332",
            modelType: .team,
            notifications: [.awards]
        )

        #expect(matchScores.id == teamID)
        #expect(awards.id == teamID)
    }

    @Test func sameKeyUnderAnotherTypeIsADifferentModel() {
        #expect(MyTBAModelID(modelType: .event, modelKey: "frc7332") != teamID)
    }

    @Test func subscribableModelMatchesItsFavorite() {
        let subscribable = Subscribable(modelKey: "frc7332", modelType: .team)
        let favorite = MyTBAFavorite(modelKey: "frc7332", modelType: .team)

        #expect(subscribable.myTBAModelID == favorite.id)
    }

    @Test func modelIDIdentifiesItself() {
        #expect(teamID.myTBAModelID == teamID)
    }
}

private struct Subscribable: MyTBASubscribable {
    let modelKey: String
    let modelType: MyTBAModelType
    static var notificationTypes: [NotificationType] { [] }
}
