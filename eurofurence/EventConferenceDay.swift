//
//  EventConferenceDay.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class EventConferenceDay: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Name = ""
    dynamic var Date = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<EventConferenceDay>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let sortProperties = [SortDescriptor(property: "Date")]
            let eventConferenceDay = realm.objects(EventConferenceDay).sorted(sortProperties)
            return eventConferenceDay
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> EventConferenceDay?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventConferenceDay = realm.objectForPrimaryKey(EventConferenceDay.self, key: primaryKey)
            return eventConferenceDay
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}