import FirebaseAuth
import GoogleSignIn
import UIKit

@MainActor
final class GoogleIdentityProvider: IdentityProviding {

    let kind: AuthProviderKind = .google

    func credential(presenting viewController: UIViewController) async throws -> AuthCredential {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            return try Self.credential(from: result.user)
        } catch let error as NSError where error.code == GIDSignInError.canceled.rawValue {
            throw AuthError.canceled
        }
    }

    func restoreCredential() async throws -> AuthCredential? {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else {
            return nil
        }
        do {
            return try Self.credential(from: await GIDSignIn.sharedInstance.restorePreviousSignIn())
        } catch let error as NSError
            where error.code == GIDSignInError.hasNoAuthInKeychain.rawValue
        {
            return nil
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    func handle(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    private static func credential(from user: GIDGoogleUser) throws -> AuthCredential {
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.missingIDToken(.google)
        }
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
    }
}
