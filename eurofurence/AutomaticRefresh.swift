//
//  AutomaticRefresh.swift
//  eurofurence
//
//  Created by Dominik Schöner on 14/08/16.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class AutomaticRefresh {
    var refreshTimer: Timer? = nil
    
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
            refreshTimer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshTime), target: self, selector: #selector(AutomaticRefresh.refreshData), userInfo: nil, repeats: true)
        }
    }
    
    @objc func refreshData() {
        if (ApiManager.sharedInstance.reachability?.isReachableViaWiFi ?? false) || UserSettings<Bool>.AutomaticRefreshOnMobile.currentValue() {
            ApiManager.sharedInstance.updateAllEntities(false, completion: { isDataUpdated in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: nil)
            })
        }
    }
}
