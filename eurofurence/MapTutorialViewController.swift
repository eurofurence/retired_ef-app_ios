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
    @IBAction func quitTutorialButton(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "appRunningForTheFirstTime")
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        showApp()
    }
    
    func showApp() {
        ConfigManager.sharedInstance.createSliderMenu(UIApplication.sharedApplication().delegate!.window!);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.quitTutorialButtonDesign.layer.borderColor = UIColor.white.cgColor
        self.quitTutorialButtonDesign.layer.borderWidth = 1.5
        
        self.quitTutorialButtonDesign.tintColor = UIColor.white
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
