import Foundation
import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : NSStringFromClass(TestAppDelegate.self)
}

let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateClassName())
