//
//  ApiManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftyJSON

class ApiManager {
    static let LAST_DATABASE_UPDATE_DEFAULT = "lastDatabaseUpdate"
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    static let sharedInstance = ApiManager()
    let entities = [
        ConfigManager.sharedInstance.eventEntry,
        ConfigManager.sharedInstance.eventConferenceTrack,
        ConfigManager.sharedInstance.eventConferenceDay,
        ConfigManager.sharedInstance.eventConferenceRoom,
        ConfigManager.sharedInstance.infoGroup,
        ConfigManager.sharedInstance.info,
        ConfigManager.sharedInstance.announcement,
        ConfigManager.sharedInstance.dealer,
        ConfigManager.sharedInstance.map
    ]
    private var requestedObjects = 0
    private var isUpdating = false
    
    func deleteEntityData(entityInstance:Object, _ prune:Bool = true) {
        if entityInstance.respondsToSelector("setIsDeleted:") || !prune {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try! Realm()
            let predicate = NSPredicate(format: "IsDeleted = %@", "1")
            let results = realm.objects(entityInstance.dynamicType)
            if prune {
                results.filter(predicate)
            }
            try! realm.write {
                realm.delete(results)
            }
        }
    }
    
    /// Checks whether Realm is still valid, otherwise causes a next refresh to 
    /// reload all data from the backend
    private func verifyRealm() {
        if Endpoint.get() == nil {
            print("Realm verification failed! Full update from backend required!")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.removeObjectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
            //TODO: Clear image cache
        }
    }
    
    func getAllFromAlert(alert: UIAlertAction) -> Void {
        updateAllEntities()
    }
    
    func updateAllEntities(forceUpdate: Bool = false, completion: ((isDataUpdated: Bool) -> Void)? = nil) {
        // Check whether we're already running an update
        if isUpdating {
            return
        }
        isUpdating = true
        LoadingOverlay.sharedInstance.changeMessage("Downloading data...");
        LoadingOverlay.sharedInstance.showOverlay()
        verifyRealm()
        
        updateEntity(ConfigManager.sharedInstance.endpoint, completion: { (result:String, isSuccessful:Bool) in
            let defaults = NSUserDefaults.standardUserDefaults()
            let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? NSDate
            let endpoint = Endpoint.get()
            var endpointCurrentDateTimeUtc: NSDate?
            
            // We need Endpoint to be available to start with our update
            if endpoint != nil {
                
                endpointCurrentDateTimeUtc = endpoint!.getCurrentDateTimeUtc()
                
                if endpointCurrentDateTimeUtc == nil {
                    endpointCurrentDateTimeUtc = NSDate()
                    print("Failed to get endpoint time, falling back to device time (", endpointCurrentDateTimeUtc,")!")
                } else {
                    print("Endpoint time is", endpointCurrentDateTimeUtc!)
                }
                
                for entity in endpoint!.Entities {
                    if entity.Name != ConfigManager.sharedInstance.endpoint && (forceUpdate || lastDatabaseUpdate == nil || !self.isEntityUpToDate(entity.Name)) {
                        print("Updating entity", entity.Name, "from", entity.LastChangeDateTimeUtc)
                        self.requestedObjects += 1
                        
                        if !self.updateEntity(entity.Name, since: lastDatabaseUpdate, completion: {
                            (result: String, isSuccessful:Bool) in
                            self.requestedObjects -= 1
                            if (self.requestedObjects == 0) {
                                LoadingOverlay.sharedInstance.hideOverlay()
                                //Find a way to show loader on cacheAllImages (Slow perf on this)
                                ImageManager.sharedInstance.cacheAllImages()
                                NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: nil)
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(endpointCurrentDateTimeUtc, forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
                                if completion != nil {
                                    completion!(isDataUpdated: true)
                                }
                                self.isUpdating = false
                            }
                            if !isSuccessful {
                                print("Error during update of ", entity.Name, ":",result)
                            } else {
                                print("Entity", entity.Name, "updated successfully")
                            }
                        }) {
                            self.requestedObjects -= 1
                            print("Entity", entity.Name, "failed to instantiate")
                        }
                    }
                }
            }
            
            // Seems nothing was updated, so we need to clean up on our own
            if self.isUpdating && self.requestedObjects == 0 {
                print("Nothing to update")
                LoadingOverlay.sharedInstance.hideOverlay()
                if forceUpdate {
                    ImageManager.sharedInstance.cacheAllImages()
                }
                if endpointCurrentDateTimeUtc != nil {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(endpointCurrentDateTimeUtc, forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
                }
                self.isUpdating = false
                if completion != nil {
                    completion!(isDataUpdated: false)
                }
            }
        })
    }
    
    /// Fetches current data from API endpoint `entityName` into Realm, calling
    /// `completion` once done.
    ///
    /// - parameters:
    ///     - entityName: Name of the API endpoint
    ///     - since: (Optional) fetches only entries updated since given NSDate
    ///     - completion: (Optional) function to be called upon completion with 
    ///         detailed information on result as parameter
    /// - returns: `true` if update was successfully triggered (this does not 
    ///     neccessarily mean that the update also completed successfully!)
    func updateEntity(entityName:String, since:NSDate? = nil, completion: ((result: String, isSuccessful: Bool) -> Void)? = nil)->Bool {
        let queue = dispatch_queue_create("com.cnoon.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        let url = ConfigManager.sharedInstance.apiBaseUrl + entityName
        
        if let entityInstance = ObjectFromString.sharedInstance.instanciate(entityName) as? Object {
            
            var parameters: [String:AnyObject] = [:]
            if since != nil {
                parameters["since"] = NSDate.ISOStringFromDate(since!)
            }
            
            print("Requesting data for", entityName, "since", since)
            let request = Alamofire.request(.GET, url, encoding: .JSON)
            request.response(
                queue: queue,
                responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
                completionHandler: { response in
                    var isSuccessful = false
                    switch (response.result) {
                    case .Success:
                        // delete entity data from cache if it is too outdated for an update
                        if !self.isEntityDeltaSufficient(entityName) {
                            self.deleteEntityData(entityInstance, false)
                        }
                        isSuccessful = true
                        Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config
                        let realm = try! Realm()
                        if let responseArray = response.result.value! as? NSArray {
                            for reponseObject in responseArray {
                                let responseJSON = JSON(reponseObject)
                                try! realm.write {
                                    realm.create(entityInstance.dynamicType, value: responseJSON.object, update: true)
                                }
                            }
                        } else {
                            let responseJSON = JSON(response.result.value!)
                            try! realm.write {
                                realm.create(entityInstance.dynamicType, value: responseJSON.object, update: true)
                            }
                        }
                        break
                    case .Failure:
                        print("Request for", entityName, "failed!");
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.deleteEntityData(entityInstance)
                        if completion != nil {
                            completion!(result: response.result.debugDescription, isSuccessful: isSuccessful)
                        }
                    }
                }
            )
            return true
        } else {
            return false
        }
        
    }
    
    func getLastUpdate()->NSDate? {
        verifyRealm()
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? NSDate
    }
    
    /// Checks whether the database has been downloaded at least once
    func isDatabaseDownloaded()->Bool {
        verifyRealm()
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) != nil
    }
    
    /// Checks whether data for given entity should be updated
    func isEntityUpToDate(entityName: String)->Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? NSDate, let endpoint = Endpoint.get(), let entity = endpoint.getEntityByName(entityName), let entityLastChanged = NSDate.dateFromISOString(entity.LastChangeDateTimeUtc) {
            
            return entityLastChanged.compare(lastDatabaseUpdate) == NSComparisonResult.OrderedAscending
        }
        return false
    }
    
    
    /// Checks whether the current delta is sufficient for updating (`true`) or 
    /// all data for the entity should be flushed for a full refresh (`false`).
    func isEntityDeltaSufficient(entityName: String)->Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? NSDate, let endpoint = Endpoint.get(), let entity = endpoint.getEntityByName(entityName), let entityDeltaStart = NSDate.dateFromISOString(entity.DeltaStartDateTimeUtc) {
            
            return entityDeltaStart.compare(lastDatabaseUpdate) == NSComparisonResult.OrderedAscending
        }
        return false
    }
    
    //TODO implement post
    func post() {
        
    }
    
}