import Foundation

public enum AuthError: LocalizedError, Equatable, Sendable {
    case canceled
    case notSignedIn
    case unsupportedProvider(AuthProviderKind)
    case missingIDToken(AuthProviderKind)
    case unexpectedCredentialType
    case noPresentationAnchor
    case nonceGenerationFailed(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "Sign in was canceled."
        case .notSignedIn:
            return "Not signed in."
        case .unsupportedProvider(let kind):
            return "Signing in with \(kind.rawValue) isn't supported."
        case .missingIDToken(let kind):
            return "\(kind.rawValue) didn't return an ID token."
        case .unexpectedCredentialType:
            return "Received an unexpected credential type."
        case .noPresentationAnchor:
            return "Unable to find a window to present sign in from."
        case .nonceGenerationFailed(let status):
            return "Unable to generate a nonce (OSStatus \(status))."
        }
    }
}
