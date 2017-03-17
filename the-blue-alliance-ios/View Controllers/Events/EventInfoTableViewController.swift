//
//  EventInfoTableViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

enum EventInfoSection: Int {
    case title
    case detail
    case link
    case max
}

enum EventDetailRow: Int {
    case alliances
    case districtPoints
    case stats
    case awards
    case max
}

enum EventLinkRow: Int {
    case website
    case twitter
    case youtube
    case chiefDelphi
    case max
}

class EventInfoTableViewController: UITableViewController {

    public var event: Event!
    
    var showAlliances: (() -> ())?
    var showDistrictPoints: (() -> ())?
    var showStats: (() -> ())?
    var showAwards: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventInfoSection.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EventInfoSection.title.rawValue:
            return 1
        case EventInfoSection.detail.rawValue:
            // Only show Alliances, Stats, and Awards if event isn't a district
            let max = EventDetailRow.max.rawValue
            return event.district != nil ? max : max - 1
        case EventInfoSection.link.rawValue:
            return EventLinkRow.max.rawValue
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            switch indexPath.section {
            case EventInfoSection.title.rawValue:
                return self.tableView(tableView, titleCellForRowAt: indexPath)
            case EventInfoSection.detail.rawValue:
                return self.tableView(tableView, detailCellForRowAt: indexPath)
            case EventInfoSection.link.rawValue:
                return self.tableView(tableView, linkCellForRowAt: indexPath)
            default:
                return UITableViewCell()
            }
        }()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        
        cell.textLabel?.text = event.name
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, detailCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        
        var row = indexPath.row
        if event.district == nil && row >= EventDetailRow.districtPoints.rawValue {
            row += 1
        }
        
        switch row {
        case EventDetailRow.alliances.rawValue:
            cell.textLabel?.text = "Alliances"
        case EventDetailRow.districtPoints.rawValue:
            cell.textLabel?.text = "District Points"
        case EventDetailRow.stats.rawValue:
            cell.textLabel?.text = "Stats"
        case EventDetailRow.awards.rawValue:
            cell.textLabel?.text = "Awards"
        default:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, linkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        
        switch indexPath.row {
        case EventLinkRow.website.rawValue:
            cell.textLabel?.text = "View event's website"
        // TODO: Core Data is generating these keys as optionals and it shouldn't...
        case EventLinkRow.twitter.rawValue:
            cell.textLabel?.text = "View #\(event.key!) on Twitter"
        case EventLinkRow.youtube.rawValue:
            cell.textLabel?.text = "View \(event.key!) on YouTube"
        case EventLinkRow.chiefDelphi.rawValue:
            cell.textLabel?.text = "View photos on Chief Delphi"
        default:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == EventInfoSection.detail.rawValue {
            var row = indexPath.row
            if event.district == nil && row >= EventDetailRow.districtPoints.rawValue {
                row += 1
            }

            switch row {
            case EventDetailRow.alliances.rawValue:
                if let showAlliances = showAlliances {
                    showAlliances()
                }
            case EventDetailRow.districtPoints.rawValue:
                if let showDistrictPoints = showDistrictPoints {
                    showDistrictPoints()
                }
            case EventDetailRow.stats.rawValue:
                if let showStats = showStats {
                    showStats()
                }
            case EventDetailRow.awards.rawValue:
                if let showAwards = showAwards {
                    showAwards()
                }
            default:
                break
            }
        } else if indexPath.section == EventInfoSection.link.rawValue {
            var urlString: String?
            switch indexPath.row {
            case EventLinkRow.website.rawValue:
                urlString = event.website
            case EventLinkRow.twitter.rawValue:
                urlString = "https://twitter.com/search?q=%23\(event.key!)"
            case EventLinkRow.youtube.rawValue:
                urlString = "https://www.youtube.com/results?search_query=\(event.key!)"
            case EventLinkRow.chiefDelphi.rawValue:
                urlString = "http://www.chiefdelphi.com/media/photos/tags/\(event.key!)"
            default:
                break
            }
            
            if let urlString = urlString {
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
