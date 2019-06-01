import Firebase
import Foundation

// TODO: Subclass AppDelegate and override some of the properties to make things testable
class TestAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.setupAppearance()
        // Setup our Firebase app - make sure this is called before other Firebase setup
        FirebaseApp.configure()
        return true
    }

}

// Note: Terrible, gross code to stub fatalError for testing.
// https://gist.github.com/mohamede1945/95e5988d1a45f44a1d9f

// overrides Swift global `fatalError`
func fatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
    unreachable()
}

/// This is a `noreturn` function that pauses forever
func unreachable() -> Never {
    repeat {
        RunLoop.current.run()
    } while (true)
}

/// Utility functions that can replace and restore the `fatalError` global function.
struct FatalErrorUtil {

    // Called by the custom implementation of `fatalError`.
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    // backup of the original Swift `fatalError`
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    /// Replace the `fatalError` global function with something else.
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
