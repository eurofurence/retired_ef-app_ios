//
//  InfosPageViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 29/04/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class InfosTutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))))
        {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound , .alert , .badge], categories: nil))
        }
        else
        {
            //
        }
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
