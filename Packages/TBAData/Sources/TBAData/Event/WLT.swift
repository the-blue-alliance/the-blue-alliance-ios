import Foundation

@objc(WLT)
public class WLT: NSObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool {
        return true
    }

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
        aCoder.encode(wins, forKey: "wins")
        aCoder.encode(losses, forKey: "losses")
        aCoder.encode(ties, forKey: "ties")
    }

    public var stringValue: String {
        return "\(wins)-\(losses)-\(ties)"
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(wins)
        hasher.combine(losses)
        hasher.combine(ties)
        return hasher.finalize()
    }

}

@objc(WLTTransformer)
class WLTTransformer: NSSecureUnarchiveFromDataTransformer {

    override class var allowedTopLevelClasses: [AnyClass] {
        return [WLT.self]
    }

}
