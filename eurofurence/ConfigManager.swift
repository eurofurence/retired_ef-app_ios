//
//  ConfigManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireImage
import SlideMenuControllerSwift

class ConfigManager {
    let apiBaseUrl = "https://app.eurofurence.org/api/"
    let endpoint = "Endpoint"
    let eventEntry = "EventEntry"
    let eventConferenceTrack = "EventConferenceTrack"
    let eventConferenceDay = "EventConferenceDay"
    let eventConferenceRoom = "EventConferenceRoom"
    let infoGroup = "InfoGroup"
    let info = "Info"
    let announcement = "Announcement"
    let image = "Image"
    let dealer = "Dealer"
    let map = "Map"
    let mapEntry = "MapEntry"
    let entityBadgeTabBar = ["Announcement" : 0, "Info" : 1, "Dealer" : 2, "Map" : 3]
    var appVersion = ""
    let slideMenuController = SlideMenuController()
    let config = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: 18,
        deleteRealmIfMigrationNeeded: true,
        fileURL: NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("cache.realm")),
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
            if (oldSchemaVersion < 2) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
    })
    
    static let sharedInstance = ConfigManager()
    
    init() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        }
    }
    
    func createSliderMenu(window: UIWindow?) {
        let menuStoryboard = UIStoryboard(name: "SlideMenu", bundle: nil);
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let mainViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        let leftViewController = menuStoryboard.instantiateViewControllerWithIdentifier("LeftView") as! LeftViewController
        
        let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController);
        window?.rootViewController = slideMenuController;
        window?.makeKeyAndVisible();
    }
    
    func diskImageDownloader(diskSpaceMB: Int = 150) -> ImageDownloader {
        let diskCapacity = diskSpaceMB * 1024 * 1024
        let diskCache = NSURLCache(memoryCapacity: 0, diskCapacity: diskCapacity, diskPath: "image_disk_cache")
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.URLCache = diskCache;
        let downloader = ImageDownloader(configuration: configuration,     downloadPrioritization: .FIFO, maximumActiveDownloads: 10)
        UIImageView.af_sharedImageDownloader = downloader
        return downloader
    }
}