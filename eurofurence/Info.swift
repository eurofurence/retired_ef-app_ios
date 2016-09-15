//
//  Info.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class InfoImageId: Object {
    dynamic var Id = ""
    let owners = LinkingObjects(fromType: Info.self, property: "ImageIdsAlternative")
}

class InfoUrl: Object {
    dynamic var Target = ""
    dynamic var Text = ""
    let owners = LinkingObjects(fromType: Info.self, property: "Urls")
    
    override static func primaryKey() -> String? {
        return "Target"
    }
}

class Info: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Title = ""
    dynamic var Text = ""
    dynamic var InfoGroupId = ""
    dynamic var Position = ""
    let ImageIdsAlternative = List<InfoImageId>()
    let Urls = List<InfoUrl>()
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Info>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let info = realm.objects(Info)
            return info
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(_ primaryKey:String) -> Info?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let info = realm.objectForPrimaryKey(Info.self, key: primaryKey)
            return info
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByGroupId(_ primaryKey:String) -> Results<Info>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let predicate = NSPredicate(format: "InfoGroupId = %@", primaryKey)
            let info = realm.objects(Info).filter(predicate).sorted("Position")
            return info
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    
}
