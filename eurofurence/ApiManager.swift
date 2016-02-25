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
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    static let sharedInstance = ApiManager()
    let objects = [ConfigManager.sharedInstance.eventEntry, ConfigManager.sharedInstance.eventConferenceTrack, ConfigManager.sharedInstance.eventConferenceDay, ConfigManager.sharedInstance.eventConferenceRoom, ConfigManager.sharedInstance.infoGroup, ConfigManager.sharedInstance.info]
    var requestedObjects = 0
    
    func getAllFromAlert(alert: UIAlertAction) -> Void {
        LoadingOverlay.sharedInstance.showOverlay()
        for object in self.objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                self.get(objectInstance as! Object, objectName: object, completion: {
                    (result: String) in
                    self.requestedObjects++;
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
        for object in self.objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                self.get(objectInstance as! Object, objectName: object, completion: {
                    (result: String) in
                    return
                });
            } else {
                print("Object failed to instanciate");
            }
        }
    }
    
    func get(dbObject:Object, objectName:String, completion: (result: String) -> Void) {
        let queue = dispatch_queue_create("com.cnoon.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        let url = ConfigManager.sharedInstance.apiBaseUrl + objectName
        print(url);
        let request = Alamofire.request(.GET, url, encoding: .JSON)
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                switch (response.result) {
                case .Success:
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

                // To update anything on the main thread, just jump back on like so.
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: "test")
                }
            }
        )
        
    }
    
    //TODO implement post
    func post() {
        
    }
    
}