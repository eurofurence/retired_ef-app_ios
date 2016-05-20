//
//  InfoViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 04/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var InfoTitleLabel: UILabel!
    @IBOutlet weak var InfoDescTextView: UITextView!
    var info = Info();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.InfoTitleLabel.text = self.info.Title;
        self.InfoDescTextView.text = self.info.Text;
        
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
