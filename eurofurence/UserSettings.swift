//
//  UserSettings.swift
//  eurofurence
//
//  Created by Dominik Schöner on 13/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

enum UserSettings<T>: String {
    case UpdateOnStart
    case RefreshInBackground
    case NotifyOnAnnouncement
    
    func defaultValue()->T {
        switch self {
        case .UpdateOnStart:
            return true as! T
        case .RefreshInBackground:
            return 15 as! T
        case .NotifyOnAnnouncement:
            return true as! T
        }
    }
    
    func currentValue()->T {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let value = defaults.objectForKey(self.rawValue) {
            return value as! T
        } else {
            return self.defaultValue()
        }
    }
    
    func setValue(value: AnyObject)->T {
        let defaults = NSUserDefaults.standardUserDefaults()
        let oldValue = self.currentValue()
        defaults.setObject(value, forKey: self.rawValue)
        return oldValue
    }
}