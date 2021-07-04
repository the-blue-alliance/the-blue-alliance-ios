//
//  TBASession.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

// A weird layer on top of URLSession for testing purposes
public protocol TBASession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
