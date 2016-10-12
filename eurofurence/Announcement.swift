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
    dynamic var ValidFromDateTimeUtc = ""
    dynamic var ValidUntilDateTimeUtc = ""
    dynamic var Area = ""
    dynamic var Author = ""
    dynamic var IsDeleted = ""
    dynamic var Title = ""
    dynamic var Content = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Announcement>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let announcement = realm.objects(Announcement.self)
            return announcement
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(_ primaryKey:String) -> Announcement?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let announcement = realm.object(ofType: Announcement.self, forPrimaryKey: primaryKey)
            return announcement
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
}
