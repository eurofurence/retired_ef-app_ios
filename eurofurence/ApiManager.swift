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
    var lastDateTimeUtc = ""
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    static let sharedInstance = ApiManager()
    let objects = [ConfigManager.sharedInstance.eventEntry, ConfigManager.sharedInstance.eventConferenceTrack, ConfigManager.sharedInstance.eventConferenceDay, ConfigManager.sharedInstance.eventConferenceRoom, ConfigManager.sharedInstance.infoGroup, ConfigManager.sharedInstance.info, ConfigManager.sharedInstance.announcement, ConfigManager.sharedInstance.dealer, ConfigManager.sharedInstance.map]
    var requestedObjects = 0
    
    func deleteOldElements(dbObject:Object) {
        Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
        let realm = try! Realm()
        let predicate = NSPredicate(format: "IsDeleted = %@", "1")
        let results = realm.objects(dbObject.dynamicType).filter(predicate)
        try! realm.write {
            realm.delete(results);
        }
        
    }
    
    func getAllFromAlert(alert: UIAlertAction) -> Void {
        LoadingOverlay.sharedInstance.showOverlay()
        for object in self.objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                self.get(objectInstance as! Object, objectName: object, completion: {
                    (result: String) in
                    self.requestedObjects += 1;
                    if (self.requestedObjects == self.objects.count) {
                        LoadingOverlay.sharedInstance.hideOverlay()
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(true, forKey: "isDatabaseAlreadyDownloaded")
                        self.requestedObjects = 0
                    }
                });
            } else {
                print("Object failed to instanciate");
                
            }
        }
    }
    
    func getAll() {
        LoadingOverlay.sharedInstance.showOverlay()
        for object in self.objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                self.get(objectInstance as! Object, objectName: object, completion: {
                    (result: String) in
                    self.requestedObjects += 1;
                    if (self.requestedObjects == self.objects.count) {
                        LoadingOverlay.sharedInstance.hideOverlay()
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(true, forKey: "isDatabaseAlreadyDownloaded")
                        self.requestedObjects = 0
                    }
                    return
                });
            } else {
                print("Object failed to instanciate");
            }
        }
    }
    
    func getDiff() {
        if (self.lastDateTimeUtc != "") {
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try! Realm();
            let endpoints = realm.objects(Endpoint);
            let lastChange = NSDate.dateFromISOString((endpoints.first?.Entities.first?.LastChangeDateTimeUtc)!);
            let lastCall = NSDate.dateFromISOString(self.lastDateTimeUtc);
            let compareResult = lastCall.compare(lastChange);
            if (compareResult == NSComparisonResult.OrderedAscending) {
                getAll()
            }
        }
        else {
            getAll();
        }
        getEndPoint({
            (result: String) in
            Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
            let realm = try! Realm()
            let endpoints = realm.objects(Endpoint);
            if (ApiManager.sharedInstance.lastDateTimeUtc == "") {
                self.lastDateTimeUtc = (endpoints.first?.CurrentDateTimeUtc)!;
            }
            }
        )
        
    }
    
    func getEndPoint(completion: (result: String) -> Void) {
        let queue = dispatch_queue_create("com.cnoon.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        let url = ConfigManager.sharedInstance.apiBaseUrl + "Endpoint"
        let request = Alamofire.request(.GET, url, encoding: .JSON)
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                switch (response.result) {
                case .Success:
                    Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
                    let realm = try! Realm()
                    let responseDictionary = response.result.value! as! NSDictionary
                    let test = JSON(responseDictionary)
                    try! realm.write {
                        realm.create(Endpoint.self, value: test.object, update: true)
                    }
                    
                    
                case .Failure:
                    print("Error with api manager");
                }
                
                // To update anything on the main thread, just jump back on like so.
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: "test")
                }
            }
        )
    }
    
    func get(dbObject:Object, objectName:String, completion: (result: String) -> Void) {
        let queue = dispatch_queue_create("com.cnoon.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        let url = ConfigManager.sharedInstance.apiBaseUrl + objectName;
        let request = Alamofire.request(.GET, url, encoding: .JSON)
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                switch (response.result) {
                case .Success:
                    Realm.Configuration.defaultConfiguration = ConfigManager.sharedInstance.config;
                    let realm = try! Realm()
                    let responseArray = response.result.value! as! NSArray
                    for reponseObject in responseArray {
                        let responseJSON = JSON(reponseObject)
                        try! realm.write {
                            realm.create(dbObject.dynamicType, value: responseJSON.object, update: true)
                        }
                    }
                    
                case .Failure:
                    print("Error with api manager");
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.deleteOldElements(dbObject);
                    completion(result: "test")
                }
            }
        )
        
    }
    
    //TODO implement post
    func post() {
        
    }
    
}