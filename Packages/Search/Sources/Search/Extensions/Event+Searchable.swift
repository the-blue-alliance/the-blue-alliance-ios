import CoreSpotlight
import TBAData

extension Event: Searchable {

    public var searchAttributes: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: Event.entityName)

        attributeSet.displayName = safeNameYear
        attributeSet.alternateNames = [key, shortName, name].compactMap({ $0 }) // Queryable by short name or name
        // attributeSet.contentDescription = dateString
        // Date-related event stuff
        attributeSet.startDate = startDate
        attributeSet.endDate = endDate
        attributeSet.allDay = NSNumber(value: 1)

        // Location-related event stuff
        attributeSet.city = city
        attributeSet.country = country
        if let lat = lat {
            attributeSet.latitude = NSNumber(value: lat)
        }
        if let lng = lng {
            attributeSet.longitude = NSNumber(value: lng)
        }
        attributeSet.namedLocation = locationName
        attributeSet.stateOrProvince = stateProv
        attributeSet.fullyFormattedAddress = address
        attributeSet.postalCode = postalCode

        return attributeSet
    }

    public var webURL: URL {
        return URL(string: "https://www.thebluealliance.com/event/\(key)")!
    }

}
