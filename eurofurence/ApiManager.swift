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
    
    func getAll() {
        let objects = ["EventEntry"]
        for object in objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                self.get(objectInstance as! Object, objectName: object);
                print(objectInstance);
                
            } else {
                print("Object failed to instanciate");
                
            }
        }
    }
    
    func get(dbObject:Object, objectName:String) {
        let queue = dispatch_queue_create("com.cnoon.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        let url = ConfigManager.sharedInstance.apiBaseUrl + objectName
        print(url);
        let request = Alamofire.request(.GET, url, encoding: .JSON)
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                let realm = try! Realm()
                let responseArray = response.result.value! as! NSArray
                for reponseObject in responseArray {
                    let responseJSON = JSON(reponseObject)
                    try! realm.write {
                        realm.create(dbObject.dynamicType, value: responseJSON.object, update: true)
                    }
                }
                // To update anything on the main thread, just jump back on like so.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Am I back on the main thread: \(NSThread.isMainThread())")
                }
            }
        )
        
    }
    
    //TODO implement post
    func post() {
        
    }
    
}