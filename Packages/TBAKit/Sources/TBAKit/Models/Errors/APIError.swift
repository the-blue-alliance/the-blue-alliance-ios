//
//  APIError.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidHTTPResponse
    case invalidResponse(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidHTTPResponse:
            return "Invalid HTTP response"
        case .invalidResponse(let error):
            return "Invalid response - \(error)"
        }
    }
    
}
