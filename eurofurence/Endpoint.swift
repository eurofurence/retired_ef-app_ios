//
//  Endpoint.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 27/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class ConfigurationValue: Object {
    dynamic var Id = ""
    dynamic var RessourceKey = ""
    dynamic var Value = ""
    let owners = LinkingObjects(fromType: Endpoint.self, property: "Configuration")
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}

class Entity: Object {
    dynamic var Id = ""
    dynamic var Name = ""
    dynamic var TableName = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var DeltaStartDateTimeUtc = ""
    dynamic var Count = ""
    let owners = LinkingObjects(fromType: Endpoint.self, property: "Entities")
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}

class Endpoint: Object {
    dynamic var CurrentDateTimeUtc = ""
    let Configuration = List<ConfigurationValue>()
    let Entities = List<Entity>()
    
    override static func primaryKey() -> String? {
        return "CurrentDateTimeUtc"
    }
    
    static func get() -> Endpoint?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let endpoint = realm.objects(Endpoint)
            return endpoint.first
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func getEntityByName(name: String)->Entity? {
        return Entities.filter(NSPredicate(format: "Name = %@", name)).first
    }
    
    func getEntityById(id: String)->Entity? {
        return Entities.filter(NSPredicate(format: "Id = %@", id)).first
    }
    
    func getConfigurationsById(id: String)->ConfigurationValue? {
        return Configuration.filter(NSPredicate(format: "Id = %@", id)).first
    }
    
    func getCurrentDateTimeUtc()->NSDate? {
        return NSDate.dateFromISOString(CurrentDateTimeUtc)
    }
}