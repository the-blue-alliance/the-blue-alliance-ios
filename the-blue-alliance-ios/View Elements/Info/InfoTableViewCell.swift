//
//  InfoTableViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/11/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "InfoCell"
    var event: Event? {
        didSet {
            if event != nil {
                team = nil
                configureCell()
            }
        }
    }
    var team: Team? {
        didSet {
            if team != nil {
                event = nil
                configureCell()
            }
        }
    }
    @IBOutlet private var infoStackView: UIStackView?
    

    // MARK: - Private Methods
    
    private func labelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
    
    private func titleLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        label.font = .systemFont(ofSize: 18)
        return label
    }
    
    private func subtitleLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }
    
    private func configureCell() {
        guard let infoStackView = infoStackView else {
            return
        }

        for view in infoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        if let event = event {
            if let name = event.name {
                let nameLabel = titleLabelWithText(name)
                infoStackView.addArrangedSubview(nameLabel)
            }
            if let location = event.locationName {
                let locationLabel = subtitleLabelWithText(location)
                infoStackView.addArrangedSubview(locationLabel)
            }
            if let date = event.dateString() {
                let dateLabel = subtitleLabelWithText(date)
                infoStackView.addArrangedSubview(dateLabel)
            }
        } else if let team = team {
            if let nickname = team.nickname {
                let nicknameLabel = titleLabelWithText(nickname)
                infoStackView.addArrangedSubview(nicknameLabel)
            }
            if let location = team.locationName {
                let locationLabel = subtitleLabelWithText(location)
                infoStackView.addArrangedSubview(locationLabel)
            } else {
                let location = [team.city, team.state, team.country].reduce("", { (locationString, locationPart) -> String in
                    guard let locationPart = locationPart else {
                        return locationString
                    }
                    return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
                })
                let locationLabel = subtitleLabelWithText(location)
                infoStackView.addArrangedSubview(locationLabel)
            }
            if let motto = team.motto {
                let mottoLabel = subtitleLabelWithText(motto)
                infoStackView.addArrangedSubview(mottoLabel)
            }
        }
    }
    
}
