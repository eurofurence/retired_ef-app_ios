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
            let mapEntries = realm.objects(MapEntry.self).sorted(byProperty: "Id")
            return mapEntries
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(_ primaryKey:String) -> MapEntry?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let map = realm.object(ofType: MapEntry.self, forPrimaryKey: primaryKey)
            return map
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByMapId(_ mapId:String) -> Results<MapEntry>? {
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let mapEntries = realm.objects(MapEntry.self).sorted(byProperty: "Id").filter(NSPredicate(format: "MapId = %@", mapId))
            return mapEntries
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getByTargetId(_ targetId:String) -> MapEntry? {
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let mapEntries = realm.objects(MapEntry.self).filter(NSPredicate(format: "TargetId = %@", targetId))
            return mapEntries.first
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func getAbsoluteLocationForImage(_ image: UIImage)->CGPoint? {
        if let relativeX = Double.init(RelativeX), let relativeY = Double.init(RelativeY) {
            return CGPoint(x: CGFloat(relativeX/100) * image.size.width, y: CGFloat(relativeY/100) * image.size.height)
        }
        return nil
    }
    
    func getAbsoluteTapRadiusForImage(_ image: UIImage)->CGFloat? {
        if let relativeTapRadius = Double.init(RelativeTapRadius) {
            return CGFloat(relativeTapRadius) * image.size.height
        }
        return nil
    }
}
