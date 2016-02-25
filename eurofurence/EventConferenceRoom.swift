//
//  EventConferenceRoom.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class EventConferenceRoom: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Name = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<EventConferenceRoom>?{
        do {
            let realm = try Realm()
            let eventConferenceRoom = realm.objects(EventConferenceRoom)
            return eventConferenceRoom
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> EventConferenceRoom?{
        do {
            let realm = try Realm()
            let eventConferenceRoom = realm.objectForPrimaryKey(EventConferenceRoom.self, key: primaryKey)
            return eventConferenceRoom
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}