//
//  Endpoint.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 27/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Configurations: Object {
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
    dynamic var SelectFields = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var count = ""
    let owners = LinkingObjects(fromType: Endpoint.self, property: "Entities")
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}

class Endpoint: Object {
    dynamic var Id = 0
    dynamic var CurrentDateTimeUtc = ""
    let Configuration = List<Configurations>()
    let Entities = List<Entity>()
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Endpoint>?{
        do {
            let realm = try Realm()
            let endpoint = realm.objects(Endpoint)
            return endpoint
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Endpoint?{
        do {
            let realm = try Realm()
            let endpoint = realm.objectForPrimaryKey(Endpoint.self, key: primaryKey)
            return endpoint
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}