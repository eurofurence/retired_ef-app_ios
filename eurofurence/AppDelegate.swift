//
//  AppDelegate.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 20/01/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import HockeySDK
import ReachabilitySwift
import RealmSwift
import SlideMenuControllerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        BITHockeyManager.shared().configure(withIdentifier: "73340e8de50b45d284f2f4c90d0eacdb")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().barStyle = .black
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 137/255.0, blue: 122/255.0, alpha: 1.0)
        
        //UITabBar.appearance().barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 1.0)
        UIApplication.shared.applicationIconBadgeNumber = 0;
        /*
         let notification = UILocalNotification()
         notification.alertBody = "Eurofurence app is running !"
         notification.alertAction = "open"
         notification.fireDate = NSDate(timeInterval: 20, sinceDate: NSDate())
         notification.soundName = UILocalNotificationDefaultSoundName
         notification.userInfo = ["UUID": "11_11_11", ]
         notification.category = "test"
         notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
         UIApplication.sharedApplication().scheduleLocalNotification(notification)
         */
        
        // Enable background refresh based on user settings
        if UserSettings<Int>.RefreshTimer.currentValue() > 0 && UserSettings<Bool>.RefreshInBackground.currentValue() {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
        
        
        updateOnStart()
        if (!self.isTutorialAlreadyShown()) {
            self.showTutorial()
        }
        else {
            UIApplication.shared.setStatusBarHidden(false, with: .none)
            ConfigManager.sharedInstance.createSliderMenu(self.window);
        }
        return true
    }
    
    func updateOnStart() {
        DispatchQueue.main.async {
                if let reachability = ApiManager.sharedInstance.reachability , reachability.isReachableViaWiFi || UserSettings<Bool>.AutomaticRefreshOnMobile.currentValue() {
                    if (!ApiManager.sharedInstance.isDatabaseDownloaded() && UserSettings<Bool>.UpdateOnStart.currentValue()) {
                        ApiManager.sharedInstance.updateAllEntities(true);
                    }
                    else if (UserSettings<Bool>.UpdateOnStart.currentValue()){
                        ApiManager.sharedInstance.updateAllEntities()
                    }
                } else {
                    if (UserSettings<Bool>.UpdateOnStart.currentValue() && (!UserSettings<Bool>.AutomaticRefreshOnMobile.currentValue() && !UserSettings<Bool>.AutomaticRefreshOnMobileAsked.currentValue())) {
                        UserSettings<Bool>.AutomaticRefreshOnMobileAsked.setValue(true)
                        let alert = UIAlertController(title: "Download database", message: "It seems that you are connected over cellular data, would you still like to allow updates/downloads via mobile network? It will allow you to use the app offline and can be changed in settings.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                            UserSettings<Bool>.AutomaticRefreshOnMobile.setValue(true)
                            ApiManager.sharedInstance.getAllFromAlert(action)
                        }))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // If we're not reachable via WiFi and the user has forbidden us to use mobile in background, do nothing.
        if let reachability = ApiManager.sharedInstance.reachability , !reachability.isReachableViaWiFi && !(UserSettings<Bool>.RefreshInBackgroundOnMobile.currentValue()) {
            completionHandler(.failed)
            return
        }
        
        if let viewControllers = self.window?.rootViewController?.childViewControllers  {
            var tabBarController: UITabBarController? = nil
            for viewController in viewControllers {
                if let tabBar = viewController as? UITabBarController {
                    tabBarController = tabBar
                    break
                }
            }
            
            if let viewControllers = tabBarController?.childViewControllers {
                for viewController in viewControllers {
                    if let navigationController = viewController as? UINavigationController, let newsTableViewController = navigationController.childViewControllers[0] as? NewsTableViewController {
                        newsTableViewController.fetchAnnouncements({ isSuccessful in
                            if !isSuccessful {
                                completionHandler(.failed)
                                return
                            } else {
                                let newAnnouncementIds = newsTableViewController.updateAnnouncements()
                                if newAnnouncementIds.count > 0 {
                                    completionHandler(.newData)
                                    return
                                } else {
                                    completionHandler(.noData)
                                    return
                                }
                            }
                        })
                    }
                }
            }
        }
        completionHandler(.failed)
    }
    
    func showTutorial() {
        let rootVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "TutorialPage") as! TutorialPageViewController
        rootVC.view.frame = UIScreen.main.bounds
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window!.rootViewController = rootVC
            }, completion: nil)
    }
    
    func isTutorialAlreadyShown()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "appRunningForTheFirstTime"){
            return true;
        }
        else{
            //defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            //print("App is running for the first time")
            return false;
        }
    }
    
    /**
     func updateTabBarBages(entityName: String) {
     print("updatingBadge");
     if let badgeNumber = ConfigManager.sharedInstance.entityBadgeTabBar[entityName] {
     let tabItem = self.mainTabBarController!.tabBar.items![badgeNumber];
     if let badgeCurrentValue = tabItem.badgeValue {
     var badgeCurrentValueAsNumber = Int(badgeCurrentValue);
     badgeCurrentValueAsNumber = badgeCurrentValueAsNumber! + 1;
     tabItem.badgeValue = String(badgeCurrentValueAsNumber);
     }
     }
     }
     **/
    
    func applicationWillResignActive(_ application: UIApplication) {
        AutomaticRefresh.sharedInstance.clearTimer()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AutomaticRefresh.sharedInstance.updateTimer()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //ApiManager.sharedInstance.updateAllEntities()
        //GetDiff, ReloadTable
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NewsListShouldRefresh"), object: self)
    }
    
    
    
}

