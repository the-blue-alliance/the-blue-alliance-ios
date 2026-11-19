import Foundation
import TBAAPI
import UIKit

/// A platinum sponsor, credited at the bottom of the More tab.
struct PlatinumSponsor: Codable, Equatable {

    enum LogoStyle: String, Codable {
        /// A wide logo, shown on its own.
        case wordmark
        /// A square logo, shown beside the name.
        case mark

        /// Styles this version doesn't know about draw as a wordmark.
        init(apiValue: String) {
            self = LogoStyle(rawValue: apiValue) ?? .wordmark
        }
    }

    let name: String
    let url: URL
    let logoStyle: LogoStyle
    let logoURL: URL?
    let logoURLDark: URL?

    init(name: String, url: URL, logoStyle: LogoStyle, logoURL: URL?, logoURLDark: URL?) {
        self.name = name
        self.url = url
        self.logoStyle = logoStyle
        self.logoURL = logoURL
        self.logoURLDark = logoURLDark
    }

    init?(apiSponsor: Sponsor) {
        guard let url = URL(string: apiSponsor.url) else { return nil }
        self.init(
            name: apiSponsor.name,
            url: url,
            logoStyle: LogoStyle(apiValue: apiSponsor.logoStyle),
            logoURL: apiSponsor.logoUrl.flatMap { URL(string: $0) },
            logoURLDark: apiSponsor.logoUrlDark.flatMap { URL(string: $0) }
        )
    }

    /// The logo for `style`, falling back to the other variant when that one is missing.
    func logoURL(for style: UIUserInterfaceStyle) -> URL? {
        style == .dark ? logoURLDark ?? logoURL : logoURL ?? logoURLDark
    }

    static func creditTitle(count: Int) -> String {
        count == 1 ? "Thanks to our platinum sponsor" : "Thanks to our platinum sponsors"
    }

}

/// Fetches the platinum sponsors at most once a day, keeping the last list on disk so More
/// can draw it straight away. A failed fetch keeps whatever was there before.
final class SponsorService {

    static let maxAge: TimeInterval = 24 * 60 * 60

    private struct Snapshot: Codable {
        let fetchedAt: Date
        let sponsors: [PlatinumSponsor]
    }

    private let api: any TBAAPIProtocol
    private let file: JSONFileStore<Snapshot>
    private let now: () -> Date
    private let loadData: (URL) async throws -> Data
    private var snapshot: Snapshot?
    private var images: [URL: UIImage] = [:]

    /// The last list fetched, however old. Empty until a fetch succeeds.
    var sponsors: [PlatinumSponsor] { snapshot?.sponsors ?? [] }

    init(
        api: any TBAAPIProtocol,
        fileURL: URL = SponsorService.defaultFileURL,
        now: @escaping () -> Date = Date.init,
        loadData: @escaping (URL) async throws -> Data = {
            try await URLSession.shared.data(from: $0).0
        }
    ) {
        self.api = api
        self.file = JSONFileStore(url: fileURL)
        self.now = now
        self.loadData = loadData
        self.snapshot = file.load()
    }

    func refresh() async -> [PlatinumSponsor] {
        if let snapshot, now().timeIntervalSince(snapshot.fetchedAt) < Self.maxAge {
            return snapshot.sponsors
        }
        // The credit is decoration: a 404, an outage or no network just leaves the last list up.
        guard let fetched = try? await api.getSponsors() else { return sponsors }
        let snapshot = Snapshot(
            fetchedAt: now(),
            sponsors: fetched.compactMap(PlatinumSponsor.init(apiSponsor:))
        )
        self.snapshot = snapshot
        file.save(snapshot)
        return snapshot.sponsors
    }

    /// Logos are fetched through the shared URL cache and kept in memory once decoded.
    func image(for url: URL) async -> UIImage? {
        if let image = images[url] { return image }
        guard let data = try? await loadData(url),
            let image = await UIImage(data: data)?.byPreparingForDisplay()
        else { return nil }
        images[url] = image
        return image
    }

    /// For tests that read the file back.
    func flush() async {
        await file.flush()
    }

    nonisolated static var defaultFileURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("sponsors.json")
    }

}
