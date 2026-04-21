import Foundation

// Top-level aliases for the OpenAPI-generated models so downstream code can
// say `Event` instead of `Components.Schemas.Event`. These are public so the
// main app target picks them up through `import TBAAPI`.
public typealias APIStatus = Components.Schemas.APIStatus
public typealias Award = Components.Schemas.Award
public typealias CompLevel = Components.Schemas.CompLevel
public typealias District = Components.Schemas.District
public typealias DistrictRanking = Components.Schemas.DistrictRanking
public typealias EliminationAlliance = Components.Schemas.EliminationAlliance
public typealias Event = Components.Schemas.Event
public typealias EventDistrictPoints = Components.Schemas.EventDistrictPoints
public typealias EventInsights = Components.Schemas.EventInsights
public typealias EventOPRs = Components.Schemas.EventOPRs
public typealias EventRanking = Components.Schemas.EventRanking
public typealias Match = Components.Schemas.Match
public typealias Media = Components.Schemas.Media
public typealias SearchIndex = Components.Schemas.SearchIndex
public typealias Team = Components.Schemas.Team
public typealias TeamEventStatus = Components.Schemas.TeamEventStatus
public typealias TeamSimple = Components.Schemas.TeamSimple
public typealias Webcast = Components.Schemas.Webcast
