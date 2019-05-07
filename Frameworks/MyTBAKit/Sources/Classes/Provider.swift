import Foundation

private class Weak: Hashable {
    let hashValue: Int
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
        self.hashValue = ObjectIdentifier(value).hashValue
    }

    static func ==(lhs: Weak, rhs: Weak) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/**
 Provider is an class used to manage observers that respond to a custom protocol.
 Mostly, it manages a colleciton of observers and creating weak references to observers. For an example, see the auth
 observer on myTBA
 */
public class Provider<ObserverType> {

    public init() {
        // Pass
    }

    private var weakObservers = Set<Weak>()
    private var observers: [ObserverType] {
        weakObservers = Set(weakObservers.filter { $0.value != nil })
        return weakObservers.compactMap { $0.value as? ObserverType }
    }

    public func add(observer: ObserverType) {
        let weak = Weak(value: observer as AnyObject)
        guard weak.value != nil else { return assertionFailure("ObserverType must be class bound") }
        weakObservers.insert(weak)
    }

    public func remove(observer: ObserverType) {
        let weak = Weak(value: observer as AnyObject)
        guard weak.value != nil else { return assertionFailure("ObserverType must be class bound") }
        weakObservers.remove(weak)
    }

    public func post(block: (ObserverType) -> Void) {
        observers.forEach(block)
    }
}
