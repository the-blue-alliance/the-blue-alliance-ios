//
//  Team+TBA.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

extension Team {
    /**
     The team number name for the team.
     Ex: "Team 7332"
     */
    public var teamNumberNickname: String {
        return "Team \(teamNumber)"
    }

    /**
     The team nickname, falling back to the team number name.
     Ex: "The Rawrbotz", falls back to "Team 7332"
     */
    public var displayName: String {
        return nickname ?? teamNumberNickname
    }

    public var locationString: String? {
        let location = [city, stateProv, country].reduce("", { (locationString, locationPart) -> String in
            guard let locationPart = locationPart, !locationPart.isEmpty else {
                return locationString
            }
            return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
        })
        return !location.isEmpty ? location : locationName
    }
}
