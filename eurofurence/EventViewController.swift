//
//  EventViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 05/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    var event = EventEntry()

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventSubTitleLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventDurationLabel: UILabel!
    @IBOutlet weak var eventHostLabel: UILabel!
    @IBOutlet weak var eventDescTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventDescTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.tabBarController?.tabBar.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let separators = NSCharacterSet(charactersInString: "–")
        let formatedTitle = (event.Title).componentsSeparatedByCharactersInSet(separators)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        self.eventLocationLabel.text = room?.Name
        self.eventStartTimeLabel.text = "" + formatedStartTime[0] + "h" + formatedStartTime[1]
        self.eventDurationLabel.text = ""  + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " min"
        self.title = day!.Name
        self.eventHostLabel.text = event.PanelHosts
        self.eventTitleLabel.text = formatedTitle[0]
        if (formatedTitle.count > 1) {
            self.eventSubTitleLabel.text = formatedTitle[1]
        }
        else {
             self.eventSubTitleLabel.text = ""
        }
        self.eventDescTextView.text = event.Description
        self.eventDescTextView.scrollsToTop = true
        self.eventDescTextView.scrollRangeToVisible(NSMakeRange(0, 1))
    }
    
    @IBAction func exportAsEvent(sender: AnyObject) {
        let alert = UIAlertController(title: "Export event", message: "Export the event to the calendar ?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { alert in EventManager.sharedInstance.checkCalendarAuthorizationStatus(self.event)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.eventDescTextView.setContentOffset(CGPointZero, animated: false)
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
