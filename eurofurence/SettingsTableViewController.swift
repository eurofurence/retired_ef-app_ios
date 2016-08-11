//
//  SettingsTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import Eureka

class SettingsTableViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Network")
            <<< SwitchRow("SwitchRow") { row in      // initializer
                row.title = "Automaticaly update on start"
                row.value = SettingsManager.sharedInstance.downloadOnStart;
                }.onChange { row in
                    row.updateCell()
                    (row.value ?? false) ? SettingsManager.sharedInstance.setUserDownloadOnStart() : SettingsManager.sharedInstance.setNotUserDownloadOnStart()
                }.cellSetup { cell, row in
                    
                }.cellUpdate { cell, row in

            }
            <<< ButtonRow(){
                $0.title = "Download database"
                }.onCellSelection { row in
                   ApiManager.sharedInstance.updateAllEntities(true);
            }
            +++ Section("Data Storage")
            <<< ButtonRow(){
                $0.title = "Clear cache"
                }.onCellSelection { row in
                    print("Pushed")
        }
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

    @IBAction func openMenu(sender: AnyObject) {
        showApp();
    }
    
    func showApp() {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        self.slideMenuController()?.changeMainViewController(rootVC, close: true)
    }
}
