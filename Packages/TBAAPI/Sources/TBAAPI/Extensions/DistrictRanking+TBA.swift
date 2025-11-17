//
//  DistrictRanking+TBA.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/24/25.
//

public extension DistrictRanking {
    var teamNumber: String {
        String(teamKey.trimmingPrefix("frc"))
    }
}
