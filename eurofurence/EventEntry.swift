//
//  EventEntry.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class EventEntry: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var SourceEventId = ""
    dynamic var Slug = ""
    dynamic var Title = ""
    dynamic var ConferenceTrackId = ""
    dynamic var ConferenceDayId = ""
    dynamic var ConferenceRoomId = ""
    dynamic var Abstract = ""
    dynamic var Description = ""
    dynamic var StartTime = ""
    dynamic var EndTime = ""
    dynamic var Duration = ""
    dynamic var PanelHosts = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<EventEntry>?{
        do {
            let realm = try Realm()
            let eventEntry = realm.objects(EventEntry)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> EventEntry?{
        do {
            let realm = try Realm()
            let eventEntry = realm.objectForPrimaryKey(EventEntry.self, key: primaryKey)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTitle(title:String) -> Results<EventEntry>?{
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "Title CONTAINS[c] %@", title)
            let eventEntry = realm.objects(EventEntry).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByDayId(primaryKey:String) -> Results<EventEntry>?{
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceDayId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry).filter(predicate).sorted("StartTime")
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByRoomId(primaryKey:String) -> Results<EventEntry>?{
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceRoomId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTrackId(primaryKey:String) -> Results<EventEntry>?{
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceTrackId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}