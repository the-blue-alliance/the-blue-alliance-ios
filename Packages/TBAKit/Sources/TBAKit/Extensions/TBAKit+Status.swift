//
//  TBAKit+Status.swift
//  
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

extension TBAKit {

    public func status() async throws -> APIStatus {
        let endpoint = "status"
        return try await fetch(endpoint)
    }

}
