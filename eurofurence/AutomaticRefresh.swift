//
//  AutomaticRefresh.swift
//  eurofurence
//
//  Created by Dominik Schöner on 14/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class AutomaticRefresh {
    var refreshTimer: NSTimer? = nil
    
    static let sharedInstance = AutomaticRefresh()
    
    func clearTimer() {
        if refreshTimer != nil {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    func updateTimer() {
        clearTimer()
        
        let refreshTime = UserSettings<Int>.RefreshTimer.currentValue()
        if refreshTime > 0 {
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(refreshTime), target: self, selector: #selector(AutomaticRefresh.refreshData), userInfo: nil, repeats: true)
        }
    }
    
    @objc func refreshData() {
        if (ApiManager.sharedInstance.reachability?.isReachableViaWiFi() ?? false) || UserSettings<Bool>.AutomaticRefreshOnMobile.currentValue() {
            ApiManager.sharedInstance.updateAllEntities(false, completion: { isDataUpdated in
                NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: nil)
            })
        }
    }
}