//
//  URLSession+TBA.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

extension URLSession: TBASession {

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await data(for: request, delegate: nil)
    }

}
