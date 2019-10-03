import Foundation

@objc(WLT)
public class WLT: NSObject, NSCoding {
    public var wins: Int
    public var losses: Int
    public var ties: Int

    public init(wins: Int, losses: Int, ties: Int) {
        self.wins = wins
        self.losses = losses
        self.ties = ties
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let wins = aDecoder.decodeInteger(forKey: "wins")
        let losses = aDecoder.decodeInteger(forKey: "losses")
        let ties = aDecoder.decodeInteger(forKey: "ties")

        self.init(wins: wins, losses: losses, ties: ties)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.wins, forKey: "wins")
        aCoder.encode(self.losses, forKey: "losses")
        aCoder.encode(self.ties, forKey: "ties")
    }

    public var stringValue: String {
        return "\(wins)-\(losses)-\(ties)"
    }

}
