//
//  MapEntry.swift
//  eurofurence
//
//  Created by Dominik Schöner on 07/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class MapEntry: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var MapId = ""
    dynamic var RelativeX = ""
    dynamic var RelativeY = ""
    dynamic var RelativeTapRadius = ""
    dynamic var MarkerType = ""
    dynamic var TargetId = ""
    dynamic var TargetDescription: String? = nil
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<MapEntry>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let mapEntries = realm.objects(MapEntry).sorted("Id")
            return mapEntries
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> MapEntry?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let map = realm.objectForPrimaryKey(MapEntry.self, key: primaryKey)
            return map
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByMapId(mapId:String) -> Results<MapEntry>? {
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let mapEntries = realm.objects(MapEntry).sorted("Id").filter(NSPredicate(format: "MapId = %@", mapId))
            return mapEntries
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTargetId(targetId:String) -> MapEntry? {
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let mapEntries = realm.objects(MapEntry).filter(NSPredicate(format: "TargetId = %@", targetId))
            return mapEntries.first
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}