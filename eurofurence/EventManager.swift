//
//  EventManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 08/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import EventKit
import UIKit

public class EventManager{
        let eventStore = EKEventStore()
    
        static let sharedInstance = EventManager();
    
    func requestAccessToCalendar(completion: ((accessGranted: Bool) -> Void)){
        self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(accessGranted: true);
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(accessGranted: false);
                })
            }
        })
    }
    
     func checkCalendarAuthorizationStatus(event : EventEntry) -> Void?{
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            requestAccessToCalendar() {
                accessGranted in
                if (accessGranted) {
                    self.insertEventInCalendar(event);
                }
            }
        case EKAuthorizationStatus.Authorized:
            insertEventInCalendar(event)
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied: break
        }
        return nil;
    }
    
    func insertEventInCalendar(event: EventEntry) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let ekEvent = EKEvent(eventStore: eventStore.self)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let formatedDate = day!.Date + " " + event.StartTime
        let startDate = dateFormatter.dateFromString(formatedDate)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let endDate = startDate!.dateByAddingTimeInterval( (Double(formatedDuration[0])! * 60 + Double(formatedDuration[1])!) * 60)
        ekEvent.title = event.Title;
        ekEvent.notes = event.Description;
        ekEvent.location = room?.Name;
        ekEvent.startDate = startDate!;
        ekEvent.endDate = endDate;
        ekEvent.addAlarm(EKAlarm(absoluteDate: startDate!.dateByAddingTimeInterval( -30 * 60)));
        ekEvent.calendar = self.eventStore.defaultCalendarForNewEvents;
        
        do {
            try self.eventStore.saveEvent(ekEvent, span: .ThisEvent)
            let alert = UIAlertController(title: "Export succes", message: "Event exported succefuly", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            //self.presentViewController(alert, animated: true, completion: nil)
        } catch let specError as NSError {
            print("A specific error occurred: \(specError)")
        } catch {
            print("An error occurred")
        }
        
        
    }
    
    func exportEventOnCalendar() {
        
    }
    
    func deleteFavoriteEvent() {
        
    }
    
    func addFavoriteEvent() {
        
    }
    
    func createNotification() {
        
    }
    
    
}