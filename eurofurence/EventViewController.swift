//
//  EventViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 05/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import KYCircularProgress

class EventViewController: UIViewController {

    @IBOutlet weak var eventScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        eventScrollView.scrollEnabled = true
        eventScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)
        eventScrollView.indicatorStyle = .White
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
