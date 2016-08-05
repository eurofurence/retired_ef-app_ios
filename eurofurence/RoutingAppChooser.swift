//
//  RoutingAppChooser.swift
//  eurofurence
//
//  Created by Dominik Schöner on 03/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import UIKit

class RoutingAppChooser {
    static let sharedInstance = RoutingAppChooser()
    
    private let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}").invertedSet
    private var routingApps : [String:String] = [:]
    private var currentURLs : [String:NSURL] = [:]
    var selectionAlert : UIAlertController!
    
    private init() {
        /*
         Placeholders to be used in app URL pattern
         %name%       - name of target POI
         %house%      - house number
         %street%     - street name
         %zip%        - zip code for city
         %city%       - city
         %country%    - country
         %country-a3% - ISO 3166-1 alpha-3 code for country [http://unstats.un.org/unsd/methods/m49/m49alpha.htm]
         */
        routingApps["Apple Maps"] = "http://maps.apple.com/?q=%name%,%house%,%street%,%city%,%country%"
        routingApps["Google Maps"] = "comgooglemaps://?q=%name%,%house%,%street%,%city%,%country%"
        routingApps["Navigon"] = "navigon://address/%name%/%country-a3%/%zip%/%city%/%street%/%house%"
        
        pruneUnavailableApps()
        
        selectionAlert = UIAlertController(title: "Choose Routing Application", message: "Choose which app you would like to open the location of the convention in. Please note that not all of these apps may work offline!", preferredStyle: .Alert)
        
        addAppActions()
    }
    
    private func pruneUnavailableApps() {
        var pruneCount = 0
        for routingApp in routingApps.keys {
            if !isAppAvailable(routingApp) {
                routingApps.removeValueForKey(routingApp)
                pruneCount += 1
                print("Pruned", routingApp)
            }
        }
        print("Pruned", pruneCount, "unavailable routing apps")
    }
    
    private func addAppActions() {
        for routingApp in routingApps.keys {
            let action = UIAlertAction(title: routingApp, style: .Default) { (alert: UIAlertAction!) -> Void in
                if self.currentURLs[routingApp] != nil {
                    UIApplication.sharedApplication().openURL(self.currentURLs[routingApp]!)
                } else {
                    print("Currently no URL for", routingApp, "available!")
                }
            }
            selectionAlert.addAction(action);
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
            ()
        }
        selectionAlert.addAction(cancelAction)
    }
    
    func isAppAvailable(routingApp: String)->Bool {
        return routingApps[routingApp] != nil && UIApplication.sharedApplication().canOpenURL(NSURL(string: routingApps[routingApp]!.stringByReplacingOccurrencesOfString("%", withString: ""))!)
    }
    
    func getCountryAlpha3(country: String?)->String? {
        //TODO: map english country names to alpha-3 strings
        return ""
    }
    
    private func validateForURL(text: String?)->String {
        if text == nil || text!.isEmpty {
            return ""
        } else {
            return text!.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        }
    }
    
    func getAppURLForAddress(routingApp: String, name: String, house: String, street: String, zip: String, city: String, country: String)->NSURL? {
        return getAppURLForAddress(
            routingApp,
            name: validateForURL(name),
            house: validateForURL(house),
            street: validateForURL(street),
            zip: validateForURL(zip),
            city: validateForURL(city),
            country: validateForURL(country),
            countryAlpha3: validateForURL(getCountryAlpha3(country)))
    }
    
    private func getAppURLForAddress(routingApp: String, name: String, house: String, street: String, zip: String, city: String, country: String, countryAlpha3: String)->NSURL? {
        if routingApps[routingApp] == nil {
            return nil
        } else {
            let appURL = routingApps[routingApp]!
                .stringByReplacingOccurrencesOfString("%name%", withString: name)
                .stringByReplacingOccurrencesOfString("%house%", withString: house)
                .stringByReplacingOccurrencesOfString("%street%", withString: street)
                .stringByReplacingOccurrencesOfString("%zip%", withString: zip)
                .stringByReplacingOccurrencesOfString("%city%", withString: city)
                .stringByReplacingOccurrencesOfString("%country%", withString: country)
                .stringByReplacingOccurrencesOfString("%country-a3%", withString: countryAlpha3)
            return NSURL(string: appURL)
        }
    }
    
    private func generateURLsForAddress(name: String, house: String, street: String, zip: String, city: String, country: String, countryAlpha3: String) {
        currentURLs = [:]
        for routingApp in routingApps.keys {
            currentURLs[routingApp] = getAppURLForAddress(routingApp, name: name, house: house, street: street, zip: zip, city: city, country: country, countryAlpha3: countryAlpha3)
        }
    }
    
    func getAlertForAddress(name: String, house: String, street: String, zip: String, city: String, country: String)->UIAlertController {
        generateURLsForAddress(
            validateForURL(name),
            house: validateForURL(house),
            street: validateForURL(street),
            zip: validateForURL(zip),
            city: validateForURL(city),
            country: validateForURL(country),
            countryAlpha3: validateForURL(getCountryAlpha3(country)))
        return selectionAlert
    }
}