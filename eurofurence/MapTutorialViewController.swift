//
//  MapTutorialViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class MapTutorialViewController: UIViewController {

    @IBAction func quitTutorialButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: "appRunningForTheFirstTime")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        showApp()
    }
    
    func showApp() {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        rootVC.view.frame = UIScreen.mainScreen().bounds
        UIView.transitionWithView(UIApplication.sharedApplication().delegate!.window!!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            UIApplication.sharedApplication().delegate!.window!!.rootViewController = rootVC
            }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
