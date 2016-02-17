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
            case "EventEntry":
                if let classObject = NSClassFromString("Eurofurence." + className) as? EventEntry.Type {
                    let object = classObject.init()
                    return object
            }
        default :
            print("Class not found")
        }
        return nil
    }
}