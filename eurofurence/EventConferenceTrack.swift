//
//  EventConferenceTrack.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class EventConferenceTrack: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Name = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<EventConferenceTrack>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventConferenceTrack = realm.objects(EventConferenceTrack).sorted("Name")
            return eventConferenceTrack
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(_ primaryKey:String) -> EventConferenceTrack?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventConferenceTrack = realm.objectForPrimaryKey(EventConferenceTrack.self, key: primaryKey)
            return eventConferenceTrack
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}
