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
import ReachabilitySwift
import SwiftyJSON

class ApiManager {
    static let LAST_DATABASE_UPDATE_DEFAULT = "lastDatabaseUpdate"
    static let LAST_DATABASE_UPDATE_LOCAL_DEFAULT = "lastDatabaseUpdateLocal"
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var reachability: Reachability?
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
    
    init() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
        }
        catch {
            print("Unable to initialise Reachability")
        }
    }

    func deleteEntityData(_ entityInstance:Object, _ prune:Bool = true) {
        if entityInstance.respondsToSelector("setIsDeleted:") || !prune {
            let entityType = type(of: entityInstance)
            DispatchQueue.main.async {
                autoreleasepool {
                    do {
                        let realm = try Realm(configuration: ConfigManager.sharedInstance.config)
                        let predicate = NSPredicate(format: "IsDeleted = %@", "1")
                        var results = realm.objects(entityType)
                        if prune {
                            results = results.filter(predicate)
                        }
                        try realm.write {
                            realm.delete(results)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
    }
    
    func clearCache() {
        DispatchQueue.main.async {
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
                defaults.removeObject(forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT)
                ImageManager.sharedInstance.clearCache(){
                    (result: Bool) in
                    //print("Cache cleared")
                }
            }
        }
    }
    
    /// Checks whether Realm is still valid, otherwise causes a next refresh to
    /// reload all data from the backend
    private func verifyRealm() {
        if Endpoint.get() == nil {
            //print("Realm verification failed! Full update from backend required!")
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
            defaults.removeObject(forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT)
            //TODO: Clear image cache
        }
    }
    
    func getAllFromAlert(_ alert: UIAlertAction) -> Void {
        updateAllEntities()
    }
    
    func updateAllEntities(_ forceUpdate: Bool = false, completion: ((_ isDataUpdated: Bool) -> Void)? = nil) {
        // Check reachability before updating
        if !(reachability?.isReachable ?? false) {
            notifyUnreachable()
            completion != nil ? completion!(false) : ()
            return
        }
        
        // Check whether we're already running an update
        if isUpdating {
            completion != nil ? completion!(false) : ()
            return
        }
        isUpdating = true
        LoadingOverlay.sharedInstance.changeMessage("Downloading data...");
        LoadingOverlay.sharedInstance.showOverlay()
        verifyRealm()
        
        updateEntity(ConfigManager.sharedInstance.endpoint, completion: { (result:String, isSuccessful:Bool) in
            let defaults = UserDefaults.standard
            let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? Date
            let endpoint = Endpoint.get()
            var endpointCurrentDateTimeUtc: Date?
            
            // We need Endpoint to be available to start with our update
            if endpoint != nil {
                
                endpointCurrentDateTimeUtc = endpoint!.getCurrentDateTimeUtc() as Date?
                
                if endpointCurrentDateTimeUtc == nil {
                    endpointCurrentDateTimeUtc = Date()
                    //print("Failed to get endpoint time, falling back to device time (", endpointCurrentDateTimeUtc,")!")
                } else {
                    //print("Endpoint time is", endpointCurrentDateTimeUtc!)
                }
                
                for entity in endpoint!.Entities {
                    if entity.Name != ConfigManager.sharedInstance.endpoint && (forceUpdate || lastDatabaseUpdate == nil || !self.isEntityUpToDate(entity.Name)) {
                        
                        let entityName = entity.Name
                        //print("Updating entity", entityName, "from", entity.LastChangeDateTimeUtc)
                        self.requestedObjects += 1
                        
                        if !self.updateEntity(entityName, since: lastDatabaseUpdate, completion: {
                            (result: String, isSuccessful:Bool) in
                            self.requestedObjects -= 1
                            if isSuccessful {
                                // Prune entities with isDeleted = true
                                if let entityInstance = ObjectFromString.sharedInstance.instanciate(entityName) as? Object {
                                    self.deleteEntityData(entityInstance)
                                }
                                //print("Entity", entityName, "updated successfully")
                            } else {
                                print("Error during update of ", entityName, ":",result)
                            }
                            if (self.requestedObjects == 0) {
                                self.isUpdating = false
                                ImageManager.sharedInstance.cacheAllImages(completion: {
                                    LoadingOverlay.sharedInstance.hideOverlay()
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: nil)
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setObject(endpointCurrentDateTimeUtc, forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
                                    defaults.setObject(NSDate(), forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT)
                                    if completion != nil {
                                        completion!(isDataUpdated: true)
                                    }
                                })
                            }
                        }) {
                            self.requestedObjects -= 1
                            print("Entity", entityName, "failed to instantiate")
                        }
                    }
                }
            }
            
            // Seems nothing was updated, so we need to clean up on our own
            if self.isUpdating && self.requestedObjects == 0 {
                //print("Nothing to update")
                if endpointCurrentDateTimeUtc != nil {
                    let defaults = UserDefaults.standard
                    defaults.set(endpointCurrentDateTimeUtc, forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
                }
                defaults.set(Date(), forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT)
                if completion != nil {
                    completion!(false)
                }
                self.isUpdating = false
                if forceUpdate {
                    ImageManager.sharedInstance.cacheAllImages(completion: {
                        LoadingOverlay.sharedInstance.hideOverlay()
                    })
                } else {
                    LoadingOverlay.sharedInstance.hideOverlay()
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
    func updateEntity(_ entityName: String, since: Date? = nil, completion: ((_ result: String, _ isSuccessful: Bool) -> Void)? = nil)->Bool {
        let queue = DispatchQueue(label: "com.cnoon.manager-response-queue", attributes: DispatchQueue.Attributes.concurrent)
        let url = ConfigManager.sharedInstance.apiBaseUrl + entityName
        
        if let entityInstance = ObjectFromString.sharedInstance.instanciate(entityName) as? Object {
            
            var parameters: [String:AnyObject] = [:]
            if since != nil {
                parameters["since"] = Date.ISOStringFromDate(since!)
            }
            
            //print("Requesting data for", entityName, "since", since)
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
                        
                        let entityType = type(of: entityInstance)
                        isSuccessful = true
                        dispatch_async(dispatch_get_main_queue()) {
                            autoreleasepool {
                                do {
                                    let realm = try Realm(configuration: ConfigManager.sharedInstance.config)
                                    if let responseArray = response.result.value! as? NSArray {
                                        for reponseObject in responseArray {
                                            let responseJSON = JSON(reponseObject)
                                            try! realm.write {
                                                realm.create(entityType, value: responseJSON.object, update: true)
                                            }
                                        }
                                    } else {
                                        let responseJSON = JSON(response.result.value!)
                                        try! realm.write {
                                            realm.create(entityType, value: responseJSON.object, update: true)
                                        }
                                    }
                                    if completion != nil {
                                        completion!(result: response.result.debugDescription, isSuccessful: isSuccessful)
                                    }
                                } catch let error as NSError {
                                    print(error)
                                    completion!(result: response.result.debugDescription, isSuccessful: false)
                                }
                            }
                        }
                        break
                    case .Failure:
                        print("Request for", entityName, "failed!");
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
    
    func getLastUpdate()->Date? {
        verifyRealm()
        let defaults = UserDefaults.standard
        return defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? Date
    }
    
    /// Checks whether the database has been downloaded at least once
    func isDatabaseDownloaded()->Bool {
        verifyRealm()
        let defaults = UserDefaults.standard
        return defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) != nil
    }
    
    /// Checks whether data for given entity should be updated
    func isEntityUpToDate(_ entityName: String)->Bool {
        let defaults = UserDefaults.standard
        if let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? Date, let endpoint = Endpoint.get(), let entity = endpoint.getEntityByName(entityName), let entityLastChanged = Date.dateFromISOString(entity.LastChangeDateTimeUtc) {
            
            return entityLastChanged.compare(lastDatabaseUpdate) == ComparisonResult.orderedAscending
        }
        return false
    }
    
    
    /// Checks whether the current delta is sufficient for updating (`true`) or
    /// all data for the entity should be flushed for a full refresh (`false`).
    func isEntityDeltaSufficient(_ entityName: String)->Bool {
        let defaults = UserDefaults.standard
        if let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? Date, let endpoint = Endpoint.get(), let entity = endpoint.getEntityByName(entityName), let entityDeltaStart = Date.dateFromISOString(entity.DeltaStartDateTimeUtc) {
            
            return entityDeltaStart.compare(lastDatabaseUpdate) == ComparisonResult.orderedAscending
        }
        return false
    }
    
    func notifyUnreachable() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Download database", message: "Unable to download database. You are currently not connected to WiFi or cellular network. You can disable automatic updates via settings.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    //TODO implement post
    func post() {
        
    }
    
}
