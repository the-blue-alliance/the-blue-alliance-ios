import Foundation

extension Bundle {

    var versionString: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: Int {
        if let buildVersionNumberString = infoDictionary?["CFBundleVersion"] as? String {
            return Int(buildVersionNumberString) ?? -1
        }
        return -1
    }

    var displayVersionString: String {
        return "v\(versionString ?? "0.0.0") (\(buildVersionNumber))"
    }

}
