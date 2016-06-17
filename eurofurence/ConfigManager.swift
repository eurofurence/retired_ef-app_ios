//
//  ConfigManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class ConfigManager {
    let apiBaseUrl = "https://app.eurofurence.org/api/"
    let eventEntry = "EventEntry"
    let eventConferenceTrack = "EventConferenceTrack"
    let eventConferenceDay = "EventConferenceDay"
    let eventConferenceRoom = "EventConferenceRoom"
    let infoGroup = "InfoGroup"
    let info = "Info"
    let announcement = "Announcement"
    let image = "Image"
    let dealer = "Dealer"
    
  static let sharedInstance = ConfigManager()
}