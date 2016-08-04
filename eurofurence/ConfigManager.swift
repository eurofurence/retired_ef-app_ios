//
//  ConfigManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

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
    let map = "Map"
    let config = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: 3,
        deleteRealmIfMigrationNeeded: true,
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
            if (oldSchemaVersion < 2) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
    })

  static let sharedInstance = ConfigManager()
}