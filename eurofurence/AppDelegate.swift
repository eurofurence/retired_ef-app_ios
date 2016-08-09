//
//  AppDelegate.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 20/01/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import ReachabilitySwift
import Fabric
import Crashlytics
import RealmSwift
import SlideMenuControllerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Crashlytics.self])


        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().barStyle = .Black
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 137/255.0, blue: 122/255.0, alpha: 1.0)
        
        //UITabBar.appearance().barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 1.0)
        
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
        
        NetworkManager.sharedInstance?.startNetworkManager();
        if (!self.isTutorialAlreadyShown()) {
            self.showTutorial()
        }
        else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        }
        createSliderMenu();
        return true
    }
    
    func createSliderMenu() {
        let menuStoryboard = UIStoryboard(name: "SlideMenu", bundle: nil);
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let mainViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        let leftViewController = menuStoryboard.instantiateViewControllerWithIdentifier("LeftView") as! LeftViewController
        
        let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController)
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(window?.rootViewController) {
            if (rootViewController.respondsToSelector(Selector("canRotate"))) {
                // Unlock landscape view orientations for this view controller
                return .AllButUpsideDown;
            }
        }
        
        if UIDevice.currentDevice().orientation != .Portrait {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        }
        
        // Only allow portrait (standard behaviour)
        return .Portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKindOfClass(UITabBarController)) {
            return topViewControllerWithRootViewController((rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKindOfClass(UINavigationController)) {
            return topViewControllerWithRootViewController((rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    func showTutorial() {
        let rootVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewControllerWithIdentifier("TutorialPage") as! TutorialPageViewController
        rootVC.view.frame = UIScreen.mainScreen().bounds
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.window!.rootViewController = rootVC
            }, completion: nil)
    }
    
    func isTutorialAlreadyShown()->Bool{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.stringForKey("appRunningForTheFirstTime"){
            return true;
        }
        else{
            //defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            //print("App is running for the first time")
            return false;
        }
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //ApiManager.sharedInstance.updateAllEntities()
        //GetDiff, ReloadTable
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("NewsListShouldRefresh", object: self)
    }
    
    
    
}

