//
//  ObjectManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 14/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class ObjectFromString {
    static let sharedInstance = ObjectFromString()
    
    func instanciate(className:String) -> AnyObject?{
        switch className {
        case ConfigManager.sharedInstance.endpoint:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Endpoint.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.eventEntry:
            if let classObject = NSClassFromString("Eurofurence." + className) as? EventEntry.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.eventConferenceTrack:
            if let classObject = NSClassFromString("Eurofurence." + className) as? EventConferenceTrack.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.eventConferenceRoom:
            if let classObject = NSClassFromString("Eurofurence." + className) as? EventConferenceRoom.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.eventConferenceDay:
            if let classObject = NSClassFromString("Eurofurence." + className) as? EventConferenceDay.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.infoGroup:
            if let classObject = NSClassFromString("Eurofurence." + className) as? InfoGroup.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.info:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Info.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.image:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Image.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.announcement:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Announcement.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.dealer:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Dealer.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.map:
            if let classObject = NSClassFromString("Eurofurence." + className) as? Map.Type {
                let object = classObject.init()
                return object
            }
        case ConfigManager.sharedInstance.mapEntry:
            if let classObject = NSClassFromString("Eurofurence." + className) as? MapEntry.Type {
                let object = classObject.init()
                return object
            }
        default :
            print("Class not found")
        }
        return nil
    }
}