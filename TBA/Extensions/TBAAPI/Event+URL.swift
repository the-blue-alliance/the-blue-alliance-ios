//
//  Event+URL.swift
//  TBA
//
//  Created by Zachary Orr on 11/22/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI

public enum MapProvider {
    case apple
    case google
}

extension Event {

    /// Generates a maps URL for the event's location.
    /// Requires at least city, state/province, and country to generate a URL.
    /// - Parameter provider: The map provider to use (.apple or .google)
    /// - Returns: A URL that opens the location in the specified maps app
    func mapURL(provider: MapProvider) -> URL? {
        guard let query = fullDisplayLocation else {
            return nil
        }

        switch provider {
        case .apple:
            // Apple Maps URL scheme: https://maps.apple.com/?q=QUERY
            guard let searchURL = URL(string: "https://maps.apple.com/") else {
                return nil
            }
            return searchURL.appending(queryItems: [
                URLQueryItem(name: "q", value: query)
            ])

        case .google:
            // Google Maps URL: https://www.google.com/maps/search/?api=1&query=QUERY
            guard let searchURL = URL(string: "https://www.google.com/maps/search/?api=1") else {
                return nil
            }
            return searchURL.appending(queryItems: [
                URLQueryItem(name: "query", value: query)
            ])
        }
    }

}
