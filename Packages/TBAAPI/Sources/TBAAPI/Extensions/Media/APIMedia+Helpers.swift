import Foundation

public typealias MediaBase = Components.Schemas.MediaBase
public typealias MediaType = Components.Schemas.MediaBase._TypePayload

// `Media` is a discriminated union keyed on `type`, and every branch carries the
// common fields as `value1`. Flatten that so callers read the shared fields directly.
extension Media {

    public var base: MediaBase {
        switch self {
        case .avatar(let payload): return payload.value1
        case .cdThread(let payload): return payload.value1
        case .cdphotothread(let payload): return payload.value1
        case .externalLink(let payload): return payload.value1
        case .facebookProfile(let payload): return payload.value1
        case .githubProfile(let payload): return payload.value1
        case .gitlabProfile(let payload): return payload.value1
        case .grabcad(let payload): return payload.value1
        case .imgur(let payload): return payload.value1
        case .instagramImage(let payload): return payload.value1
        case .instagramProfile(let payload): return payload.value1
        case .onshape(let payload): return payload.value1
        case .periscopeProfile(let payload): return payload.value1
        case .smugmugAlbum(let payload): return payload.value1
        case .smugmugPhoto(let payload): return payload.value1
        case .twitterProfile(let payload): return payload.value1
        case .youtube(let payload): return payload.value1
        case .youtubeChannel(let payload): return payload.value1
        }
    }

    public var type: MediaType { base._type }
    public var foreignKey: String { base.foreignKey }
    public var preferred: Bool? { base.preferred }
    public var teamKeys: [String] { base.teamKeys }
    public var directUrl: String? { base.directUrl }
    public var viewUrl: String? { base.viewUrl }

    public var avatarBase64Image: String? {
        guard case .avatar(let payload) = self else { return nil }
        return payload.value2.details?.base64Image
    }

}
