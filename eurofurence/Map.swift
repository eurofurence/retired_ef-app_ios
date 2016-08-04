//
//  Map.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 04/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Map: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var ValidFromDateTimeUtc = ""
    dynamic var ValidUntilDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var ImageId: String? = nil
    dynamic var Description: String? = nil
    dynamic var IsBrowseable: String? = nil
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Map>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let maps = realm.objects(Map).sorted("Id")
            return maps
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Map?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let map = realm.objectForPrimaryKey(Map.self, key: primaryKey)
            return map
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
}