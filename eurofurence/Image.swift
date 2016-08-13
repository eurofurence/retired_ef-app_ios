//
//  Image.swift
//  eurofurence
//
//  Created by Dominik Schöner on 13/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Image: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var Url = ""
    dynamic var Title = ""
    dynamic var Width = ""
    dynamic var Height = ""
    dynamic var FileSizeInBytes = ""
    dynamic var MimeType = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Image>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let image = realm.objects(Image)
            return image
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Image?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let image = realm.objectForPrimaryKey(Image.self, key: primaryKey)
            return image
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
}