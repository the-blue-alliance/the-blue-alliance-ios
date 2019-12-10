import CoreData
import Foundation
import MyTBAKit

@objc(MyTBAEntity)
public class MyTBAEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTBAEntity> {
        return NSFetchRequest<MyTBAEntity>(entityName: "MyTBAEntity")
    }

    @NSManaged public internal(set) var modelKey: String
    @NSManaged internal var modelTypeRaw: NSNumber

}

extension MyTBAEntity {

    public var modelType: MyTBAModelType {
        get {
            guard let modelType = MyTBAModelType(rawValue: modelTypeRaw.intValue) else {
                fatalError("Unsupported myTBA model type \(modelTypeRaw.intValue)")
            }
            return modelType
        }
        set {
            modelTypeRaw = NSNumber(value: newValue.rawValue)
        }
    }

}
