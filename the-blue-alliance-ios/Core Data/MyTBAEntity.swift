import Foundation

extension MyTBAEntity {

    var modelType: MyTBAModelType {
        get {
            return MyTBAModelType(rawValue: Int(modelTypeRaw))!
        }
        set {
            modelTypeRaw = Int32(newValue.rawValue)
        }
    }

}
