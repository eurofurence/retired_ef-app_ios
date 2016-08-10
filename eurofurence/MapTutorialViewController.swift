//
//  MapTutorialViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class MapTutorialViewController: UIViewController {

    @IBOutlet weak var quitTutorialButtonDesign: UIButton!
    @IBAction func quitTutorialButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "appRunningForTheFirstTime")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        showApp()
    }
    
    func showApp() {
        ConfigManager.sharedInstance.createSliderMenu(UIApplication.sharedApplication().delegate!.window!);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.quitTutorialButtonDesign.layer.cornerRadius = 5.0;
               self.quitTutorialButtonDesign.layer.borderColor = UIColor.whiteColor().CGColor
                       self.quitTutorialButtonDesign.layer.borderWidth = 0.5
        self.quitTutorialButtonDesign.backgroundColor = UIColor(red: 0/255.0, green: 136/255.0, blue: 121/255.0, alpha: 1.0)

                self.quitTutorialButtonDesign.tintColor = UIColor.whiteColor()
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
