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

open class EventManager{
        let eventStore = EKEventStore()
    
        static let sharedInstance = EventManager();
    
    func requestAccessToCalendar(_ completion: @escaping ((_ accessGranted: Bool) -> Void)){
        self.eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    completion(true);
                })
            } else {
                DispatchQueue.main.async(execute: {
                    completion(false);
                })
            }
        } as! EKEventStoreRequestAccessCompletionHandler)
    }
    
     func checkCalendarAuthorizationStatus(_ event : EventEntry) -> Void?{
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar() {
                accessGranted in
                if (accessGranted) {
                    self.insertEventInCalendar(event);
                }
            }
        case EKAuthorizationStatus.authorized:
            insertEventInCalendar(event)
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
        }
        return nil;
    }
    
    func insertEventInCalendar(_ event: EventEntry) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let ekEvent = EKEvent(eventStore: eventStore.self)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let formatedDate = day!.Date + " " + event.StartTime
        let startDate = dateFormatter.date(from: formatedDate)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let endDate = startDate!.addingTimeInterval( (Double(formatedDuration[0])! * 60 + Double(formatedDuration[1])!) * 60)
        ekEvent.title = event.Title;
        ekEvent.notes = event.Description;
        ekEvent.location = room?.Name;
        ekEvent.startDate = startDate!;
        ekEvent.endDate = endDate;
        ekEvent.addAlarm(EKAlarm(absoluteDate: startDate!.addingTimeInterval( -30 * 60)));
        ekEvent.calendar = self.eventStore.defaultCalendarForNewEvents;
        
        do {
            try self.eventStore.save(ekEvent, span: .thisEvent)
            let alert = UIAlertController(title: "Export succes", message: "Event exported succefuly", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
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
