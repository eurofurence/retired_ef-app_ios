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
    dynamic var ImageId:String? = nil
    dynamic var Slug = ""
    dynamic var Title = ""
    dynamic var SubTitle = ""
    dynamic var ConferenceTrackId = ""
    dynamic var ConferenceDayId = ""
    dynamic var ConferenceRoomId = ""
    dynamic var Abstract = ""
    dynamic var Description = ""
    dynamic var StartTime = ""
    dynamic var EndTime = ""
    dynamic var Duration = ""
    dynamic var PanelHosts = ""
    dynamic var IsDeviatingFromConBook = ""
    let favorited = RealmOptional<Bool>()
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<EventEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventEntry = realm.objects(EventEntry.self)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(_ primaryKey:String) -> EventEntry?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventEntry = realm.object(ofType: EventEntry.self, forPrimaryKey: primaryKey)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTitle(_ title:String) -> Results<EventEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let predicate = NSPredicate(format: "Title CONTAINS[c] %@", title)
            let eventEntry = realm.objects(EventEntry.self).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByDayId(_ primaryKey:String) -> Results<EventEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceDayId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry.self).filter(predicate).sorted(byProperty: "StartTime")
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getDayByEventId(_ primaryKey:String) -> EventConferenceDay?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let eventConferenceDay = realm.object(ofType: EventConferenceDay.self, forPrimaryKey: primaryKey)
            return eventConferenceDay
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByRoomId(_ primaryKey:String) -> Results<EventEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceRoomId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry.self).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTrackId(_ primaryKey:String) -> Results<EventEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let predicate = NSPredicate(format: "ConferenceTrackId = %@", primaryKey)
            let eventEntry = realm.objects(EventEntry.self).filter(predicate)
            return eventEntry
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}
