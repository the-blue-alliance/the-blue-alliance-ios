//
//  Models.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/24/25.
//

public typealias District = Components.Schemas.District
public typealias DistrictRanking = Components.Schemas.DistrictRanking

public typealias Event = Components.Schemas.Event

public typealias SearchIndex = Components.Schemas.SearchIndex

public typealias TeamFull = Components.Schemas.TeamFull
public typealias TeamSimple = Components.Schemas.TeamSimple

public typealias Status = Components.Schemas.APIStatus
extension Status {
    public typealias AppInfo = Components.Schemas.APIStatusAppVersion
}

public typealias Webcast = Components.Schemas.Webcast
public typealias WebcastType = Components.Schemas.Webcast._TypePayload
