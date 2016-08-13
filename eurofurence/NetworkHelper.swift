//
//  NetworkHelper.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import ReachabilitySwift

class NetworkManager {
    let reachability: Reachability?
    static let sharedInstance = NetworkManager()
    
    init?() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            self.reachability = nil;
            return;
        }
        if self.reachability == nil {
            return nil;
        }
    }
    
    func startNetworkManager() {
        self.reachability!.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    if (!ApiManager.sharedInstance.isDatabaseDownloaded() && UserSettings<Bool>.UpdateOnStart.currentValue()) {
                        ApiManager.sharedInstance.updateAllEntities(true);
                    }
                    else if (UserSettings<Bool>.UpdateOnStart.currentValue()){
                        ApiManager.sharedInstance.updateAllEntities()
                    }
                } else {
                    if (UserSettings<Bool>.UpdateOnStart.currentValue()) {
                        let alert = UIAlertController(title: "Download database", message: "It seems that you are connected over cellular data, would you like to download/update the content data, it will allow you to use the app offline?", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: ApiManager.sharedInstance.getAllFromAlert))
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        self.reachability!.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
                if (!ApiManager.sharedInstance.isDatabaseDownloaded()) {
                    let alert = UIAlertController(title: "Download database", message: "You should connect to a wifi or a cellular connexion to initiate the app data", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        do {
            try self.reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
}