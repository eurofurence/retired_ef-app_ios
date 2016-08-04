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
    
    /// Checks whether this entity is valid at the timestamp given in
    /// `dateTimeUtc`, which must adhere to the format `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
    ///
    /// - returns: true if `dateTimeUtc` is between `ValidFromDateTimeUtc` inclusive
    ///     and `ValidUntilDateTimeUtc` inclusive. If either boundary is invalid,
    ///     it will be ignored.
    func isValidAtDateTimeUtcString(dateTimeUtcString: String)->Bool {
        let dateTimeUtc = NSDate.dateFromISOString(dateTimeUtcString)
        
        return dateTimeUtc != nil && isValidAtDateTimeUtc(dateTimeUtc!)
    }
    
    /// Checks whether this entity is valid at `dateTimeUtc`.
    ///
    /// - returns: true if `dateTimeUtc` is between `ValidFromDateTimeUtc` inclusive
    ///     and `ValidUntilDateTimeUtc` inclusive. If either boundary is invalid,
    ///     it will be ignored.
    func isValidAtDateTimeUtc(dateTimeUtc: NSDate)->Bool {
        let fromDate = NSDate.dateFromISOString(ValidFromDateTimeUtc)
        let untilDate = NSDate.dateFromISOString(ValidUntilDateTimeUtc)
        
        return (fromDate == nil || dateTimeUtc.compare(fromDate!) == NSComparisonResult.OrderedDescending ||
            dateTimeUtc.compare(fromDate!) == NSComparisonResult.OrderedSame) &&
            (untilDate == nil || dateTimeUtc.compare(untilDate!) == NSComparisonResult.OrderedAscending ||
                dateTimeUtc.compare(untilDate!) == NSComparisonResult.OrderedSame)
    }
    
}