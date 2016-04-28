//
//  Announcement.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 28/04/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Announcement: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Title = ""
    dynamic var Text = ""
    dynamic var InfoGroupId = ""
    dynamic var Position = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Announcement>?{
        do {
            let realm = try Realm()
            let announcement = realm.objects(Announcement)
            return announcement
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Announcement?{
        do {
            let realm = try Realm()
            let announcement = realm.objectForPrimaryKey(Announcement.self, key: primaryKey)
            return announcement
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
}