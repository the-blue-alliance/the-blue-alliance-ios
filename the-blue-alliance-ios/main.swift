import Foundation
import UIKit

// TODO: For UI testing, check command line args to see if we're UI testing and need our host app
private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : NSStringFromClass(TestAppDelegate.self)
}

let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateClassName())
