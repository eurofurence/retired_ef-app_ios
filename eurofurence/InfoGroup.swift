//
//  InfoGroup.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class InfoGroup: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Name = ""
    dynamic var Position = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<InfoGroup>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let infoGroup = realm.objects(InfoGroup).sorted("Position")
            return infoGroup
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> InfoGroup?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let infoGroup = realm.objectForPrimaryKey(InfoGroup.self, key: primaryKey)
            return infoGroup
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}