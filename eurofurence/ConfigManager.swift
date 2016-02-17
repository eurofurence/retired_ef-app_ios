//
//  ConfigManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class ConfigManager {
    let apiBaseUrl = "http://eurofurencewebapi.azurewebsites.net/"
    let eventEntry = "EventEntry"
    let eventConferenceTrack = "EventConferenceTrack"
    let eventConferenceDay = "EventConferenceDay"
    let eventConferenceRoom = "EventConferenceRoom"
    let infoGroup = "InfoGroup"
    let info = "Info"
    let image = "Image"
    
  static let sharedInstance = ConfigManager()
}