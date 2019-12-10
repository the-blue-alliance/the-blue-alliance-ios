import CoreData
import Foundation
import MyTBAKit

@objc(MyTBAEntity)
public class MyTBAEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTBAEntity> {
        return NSFetchRequest<MyTBAEntity>(entityName: "MyTBAEntity")
    }

    @NSManaged public internal(set) var modelKey: String
    @NSManaged internal var modelTypeRaw: Int16

}

extension MyTBAEntity {

    public var modelType: MyTBAModelType {
        get {
            guard let modelType = MyTBAModelType(rawValue: Int(modelTypeRaw)) else {
                fatalError("Unsupported myTBA model type \(modelTypeRaw)")
            }
            return modelType
        }
        set {
            modelTypeRaw = Int16(newValue.rawValue)
        }
    }

}
