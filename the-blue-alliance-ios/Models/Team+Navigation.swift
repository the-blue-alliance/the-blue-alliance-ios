//
//  Team+Navigation.swift
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

extension Team {
    private func safeOpenURL(urlString:String) -> Bool {
        let maybeUrl:NSURL? = NSURL(string: urlString)
        if let url = maybeUrl {
            return UIApplication.sharedApplication().openURL(url)
        }
        return false
    }
    
    func navigateToWebsite() {
        safeOpenURL(website)
    }
    
    func navigateToTwitter() {
        if !safeOpenURL("twitter://search?query=%23\(key)") {
            safeOpenURL("https://twitter.com/search?q=%23\(key)")
        }
    }
    
    func navigateToYoutube() {
        safeOpenURL("https://www.youtube.com/results?search_query=%23\(key)+OR+%22team+\(team_numberValue)%22")
    }
    
    func navigateToChief() {
        safeOpenURL("http://www.chiefdelphi.com/media/photos/tags/\(key)")
    }
}