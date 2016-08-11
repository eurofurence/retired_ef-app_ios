//
//  SettingsManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 11/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift

class SettingsManager {
    var downloadOnStart : Bool;
    static let USER_DOWNLOAD_DB_SETTING = "userDownloadDbSetting";
    static let sharedInstance = SettingsManager()
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userDownload = defaults.objectForKey(SettingsManager.USER_DOWNLOAD_DB_SETTING)  {
            downloadOnStart = userDownload as! Bool;
        }
        else {
            downloadOnStart = true;
        }
    }
    
    func setUserDownloadOnStart() {
        self.downloadOnStart = true;
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: SettingsManager.USER_DOWNLOAD_DB_SETTING)
    }
    
    func setNotUserDownloadOnStart() {
        self.downloadOnStart = false;
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(false, forKey: SettingsManager.USER_DOWNLOAD_DB_SETTING)
    }
    
    /// Checks whether the user want to download or not the db on start
    func userNotDownloadOnStart()->Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userDownload = defaults.objectForKey(SettingsManager.USER_DOWNLOAD_DB_SETTING) {
            return userDownload as! Bool;
        }
        else {
            return false;
        }
    }
    
    func clearAllCache() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        ImageManager.sharedInstance.clearCache(){
            (result: Bool) in
            print("Cache cleared");
        };
    }
}