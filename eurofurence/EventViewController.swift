//
//  EventViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 05/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import EventKit

class EventViewController: UIViewController {
    let eventStore = EKEventStore()
    var event = EventEntry()

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventDurationLabel: UILabel!
    @IBOutlet weak var eventHostLabel: UILabel!
    @IBOutlet weak var eventDescTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        self.eventLocationLabel.text = room?.Name
        self.eventStartTimeLabel.text = "" + formatedStartTime[0] + "h" + formatedStartTime[1]
        self.eventDurationLabel.text = ""  + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " min"
        self.title = day!.Name
        self.eventHostLabel.text = event.PanelHosts
        self.eventTitleLabel.text = event.Title
        self.eventDescTextView.text = event.Description
        self.eventDescTextView.scrollsToTop = true
        self.eventDescTextView.textColor = UIColor.whiteColor()
    }
    
    @IBAction func exportAsEvent(sender: AnyObject) {
        let alert = UIAlertController(title: "Export event", message: "Export the event to the calendar ?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: checkCalendarAuthorizationStatus))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func requestAccessToCalendar() {
        self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.insertEvent()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                })
            }
        })
    }
    
    func checkCalendarAuthorizationStatus(alert:UIAlertAction) -> Void{
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            insertEvent()
            // Things are in line with being able to show the calendars in the table view
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied: break
            // We need to help them give us permission
        }
    }
    
    func insertEvent() {
        let startDate = NSDate()
        let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
        let event = EKEvent(eventStore: eventStore.self)
        event.title = "New Meeting"
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = self.eventStore.defaultCalendarForNewEvents
        
        do {
            try self.eventStore.saveEvent(event, span: .ThisEvent)
            let alert = UIAlertController(title: "Export succes", message: "Event exported succefuly", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } catch let specError as NSError {
            print("A specific error occurred: \(specError)")
        } catch {
            print("An error occurred")
        }
        
        
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
