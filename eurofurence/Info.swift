//
//  Info.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Info: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Title = ""
    dynamic var Text = ""
    dynamic var Position = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Info>?{
        do {
            let realm = try Realm()
            let info = realm.objects(Info)
            return info
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Info?{
        do {
            let realm = try Realm()
            let info = realm.objectForPrimaryKey(Info.self, key: primaryKey)
            return info
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}