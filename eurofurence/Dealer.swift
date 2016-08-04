//
//  Announcement.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 28/04/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class Dealer: Object {
    dynamic var Id = ""
    dynamic var LastChangeDateTimeUtc = ""
    dynamic var ValidFromDateTimeUtc = ""
    dynamic var ValidUntilDateTimeUtc = ""
    dynamic var IsDeleted = ""
    dynamic var RegistrationNumber: String? = nil
    dynamic var AttendeeNickname: String? = nil
    dynamic var DisplayName: String? = nil
    dynamic var ShortDescription: String? = nil
    dynamic var AboutTheArtistText: String? = nil
    dynamic var AboutTheArtText: String? = nil
    dynamic var WebsiteUri: String? = nil
    dynamic var ArtPreviewCaption: String? = nil
    dynamic var ArtistThumbnailImageId: String? = nil
    dynamic var ArtistImageId: String? = nil
    dynamic var ArtPreviewImageId: String? = nil
    
    override static func primaryKey() -> String? {
        return "Id"
    }
    
    static func getAll() -> Results<Dealer>?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let dealer = realm.objects(Dealer).sorted("AttendeeNickname")
            return dealer
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func getById(primaryKey:String) -> Dealer?{
        do {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try Realm()
            let dealer = realm.objectForPrimaryKey(Dealer.self, key: primaryKey)
            return dealer
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
}