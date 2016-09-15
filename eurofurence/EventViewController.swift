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
    @IBOutlet weak var eventLocationIconImageView: UIImageView!
    @IBOutlet weak var eventSubTitleLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventDurationLabel: UILabel!
    @IBOutlet weak var eventHostLabel: UILabel!
    @IBOutlet weak var eventDescTextView: UITextView!
    @IBOutlet weak var eventImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventImageView: UIImageView!
    var eventImageDefaultHeight = CGFloat(0.0)
    var singleTapLocation: UITapGestureRecognizer!
    var singleTapLocationIcon: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventDescTextView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        eventImageDefaultHeight = eventImageHeightConstraint.constant
        
        singleTapLocation = UITapGestureRecognizer(target: self, action: #selector(EventViewController.showOnMap(_:)))
        eventLocationLabel!.addGestureRecognizer(singleTapLocation!)
        eventLocationLabel!.isUserInteractionEnabled = true
        
        singleTapLocationIcon = UITapGestureRecognizer(target: self, action: #selector(EventViewController.showOnMap(_:)))
        eventLocationIconImageView!.addGestureRecognizer(singleTapLocationIcon!)
        eventLocationIconImageView!.isUserInteractionEnabled = true
    }
    

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        
        if let room = EventConferenceRoom.getById(event.ConferenceRoomId) {
            self.eventLocationLabel.text = room.Name
            
            if let _ = MapEntry.getByTargetId(room.Id) {
                eventLocationLabel.textColor = eventLocationLabel.tintColor
            }
        } else {
            self.eventLocationLabel.text = nil
        }
        
        self.eventStartTimeLabel.text = "" + formatedStartTime[0] + "h" + formatedStartTime[1]
        self.eventDurationLabel.text = ""  + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " min"
        self.title = day!.Name
        self.eventHostLabel.text = event.PanelHosts
        self.eventTitleLabel.text = event.Title
        self.eventSubTitleLabel.text = event.SubTitle
        self.eventDescTextView.text = event.Description
        self.eventDescTextView.scrollsToTop = true
        self.eventDescTextView.scrollRangeToVisible(NSMakeRange(0, 1))
        
        if let imageId = event.ImageId {
            eventImageView.image = ImageManager.sharedInstance.retrieveFromCache(imageId)
        } else {
            eventImageView.image = nil
        }
        if eventImageView.image != nil {
            eventImageHeightConstraint.constant = eventImageDefaultHeight
            eventImageView.sizeToFit()
        } else {
            eventImageHeightConstraint.constant = CGFloat(0.0)
        }
    }
    
    @IBAction func exportAsEvent(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Export event", message: "Export the event to the calendar ?", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { alert in EventManager.sharedInstance.checkCalendarAuthorizationStatus(self.event)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.eventDescTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    func showOnMap(_ tapGesture: UITapGestureRecognizer) {
        if let mapEntry = MapEntry.getByTargetId(event.ConferenceRoomId) {
            self.performSegue(withIdentifier: "EventDetailViewToMapSegue", sender: mapEntry)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventDetailViewToMapSegue" {
            if let destinationVC = segue.destination as? MapViewController, let mapEntry = sender as? MapEntry {
                destinationVC.currentMapEntry = mapEntry
                destinationVC.currentMapEntryRadiusMultiplier = 30.0
                self.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
}
