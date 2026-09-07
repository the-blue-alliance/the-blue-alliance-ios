import AuthenticationServices
import FirebaseAuth
import UIKit

@MainActor
final class AppleIdentityProvider: NSObject, IdentityProviding {

    let kind: AuthProviderKind = .apple

    private var anchor: ASPresentationAnchor?
    private var controller: ASAuthorizationController?
    private var continuation: CheckedContinuation<ASAuthorization, Error>?

    func credential(presenting viewController: UIViewController) async throws -> AuthCredential {
        guard continuation == nil else {
            throw AuthError.canceled
        }
        guard let window = viewController.view.window else {
            throw AuthError.noPresentationAnchor
        }
        // Local, so a second tap can't clobber it and nothing outlives the call.
        let nonce = try Nonce()

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256

        anchor = window
        let authorization: ASAuthorization = try await withCheckedThrowingContinuation {
            continuation in
            self.continuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            self.controller = controller
            controller.performRequests()
        }

        guard
            let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
            throw AuthError.unexpectedCredentialType
        }
        guard let tokenData = appleCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            throw AuthError.missingIDToken(kind)
        }

        return OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce.raw,
            fullName: appleCredential.fullName
        )
    }

    // Apple keeps no local session; signing out of Firebase is the whole story.
    func signOut() {}

    private func finish(_ result: Result<ASAuthorization, Error>) {
        guard let continuation else {
            return
        }
        self.continuation = nil
        controller = nil
        continuation.resume(with: result)
    }
}

extension AppleIdentityProvider: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Set by credential(presenting:) before performRequests(); the system
        // only asks during the request.
        return anchor!
    }

}

extension AppleIdentityProvider: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        finish(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let error = error as? ASAuthorizationError, error.code == .canceled {
            finish(.failure(AuthError.canceled))
        } else {
            finish(.failure(error))
        }
    }

}
