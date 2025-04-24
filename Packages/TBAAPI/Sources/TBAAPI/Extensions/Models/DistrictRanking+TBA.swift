//
//  DistrictRanking+TBA.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/24/25.
//

extension DistrictRanking {

    public var teamNumber: String {
        return String(teamKey.trimmingPrefix("frc"))
    }

}
