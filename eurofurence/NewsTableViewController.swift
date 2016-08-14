//
//  NewsTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 24/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import RealmSwift

class NewsTableViewController: UITableViewController {
    var annoucements = Results<Announcement>?()
    var filteredAnnouncements : [Announcement] = []
    var refreshLabelTimer: NSTimer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsTableViewController.notificationRefresh(_:)),name:"reloadData", object: nil)
        self.annoucements = Announcement.getAll()
        self.tableView.backgroundColor = UIColor.blackColor()
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension;
        self.refreshControl?.addTarget(self, action: #selector(NewsTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Reset the application badge because all announcements can be assumed seen
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    // Pull to refresh function
    func refresh(sender:AnyObject) {
        ApiManager.sharedInstance.updateAllEntities(false, completion: {(isDataUpdated: Bool) in
            if isDataUpdated {
                self.updateAnnouncements()
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        })
    }
    
    func notificationRefresh(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue()) {
            self.updateAnnouncements()
            self.tableView.reloadData()
        }
    }
    
    func updateAnnouncements()->[String] {
        self.annoucements = Announcement.getAll()
        let oldAnnouncements = self.filteredAnnouncements
        var newAnnouncementIds: [String] = []
        self.filteredAnnouncements = []
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        for announcement in annoucements! {
            
            let currentDate = NSDate();
            let utcTimeZoneStr = formatter.stringFromDate(currentDate)
            
            // Check whether we are currently within the announcements validity time frame
            if let currentDateUtc = NSDate.dateFromISOString(utcTimeZoneStr),
                let fromDate = NSDate.dateFromISOString(announcement.ValidFromDateTimeUtc),
                let untilDate = NSDate.dateFromISOString(announcement.ValidUntilDateTimeUtc)
                where (fromDate.compare(currentDateUtc) != NSComparisonResult.OrderedDescending && untilDate.compare(currentDateUtc) != NSComparisonResult.OrderedAscending) {
                
                self.filteredAnnouncements.append(announcement)
                
                // Check if we have new announcements
                if oldAnnouncements.filter({ oldAnnouncement in
                    if let oldAnnouncementDate = NSDate.dateFromISOString(oldAnnouncement.LastChangeDateTimeUtc),
                        let newAnnouncementDate = NSDate.dateFromISOString(announcement.LastChangeDateTimeUtc) {
                        return oldAnnouncement.Id == announcement.Id && oldAnnouncementDate.compare(newAnnouncementDate) != NSComparisonResult.OrderedAscending
                    } else {
                        return oldAnnouncement.Id == announcement.Id
                    }
                }).count == 0 {
                    newAnnouncementIds.append(announcement.Id)
                }
            }
        }
        
        notifyAnnouncements(newAnnouncementIds)
        return newAnnouncementIds
    }
    
    func notifyAnnouncements(announcementIds: [String]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        if UserSettings<Bool>.NotifyOnAnnouncement.currentValue() {
            for announcementId in announcementIds {
                if let announcement = Announcement.getById(announcementId) {
                    let notification = UILocalNotification()
                    notification.alertBody = announcement.Title
                    notification.timeZone = NSTimeZone(abbreviation: "UTC")
                    if let announcementDate = NSDate.dateFromISOString(announcement.ValidFromDateTimeUtc) {
                        notification.fireDate = announcementDate
                    }
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.userInfo = ["Announcement.Id": announcement.Id ]
                    notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                    
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                }
            }
        } else if announcementIds.count > 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = announcementIds.count
        }
        
        
        if let tabBarItem = self.navigationController?.tabBarItem where announcementIds.count > 0 {
            tabBarItem.badgeValue = String(announcementIds.count)
        }
    }
    
    func fetchAnnouncements(completion: (isSuccessful: Bool)->Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? NSDate
        ApiManager.sharedInstance.updateEntity("Announcement", since: lastDatabaseUpdate, completion: { result, isSuccessful in
            completion(isSuccessful: isSuccessful)
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.filteredAnnouncements.count > 0 {
            return (self.filteredAnnouncements.count + 1)
        } else {
            return 2
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateAnnouncements();
        self.tableView.reloadData();
        if let tabBarItem = self.navigationController?.tabBarItem {
            tabBarItem.badgeValue = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if refreshLabelTimer != nil {
            refreshLabelTimer?.invalidate()
            refreshLabelTimer = nil
        }
        if let tabBarItem = self.navigationController?.tabBarItem {
            tabBarItem.badgeValue = nil
        }
    }
    
    func updateRefreshLabel() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userInfo = refreshLabelTimer?.userInfo, let newsLastRefreshLabel = userInfo as? UILabel, let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT) as? NSDate {
            
            newsLastRefreshLabel.text = getLastRefreshString(lastDatabaseUpdate)
        }
    }
    
    func getLastRefreshString(lastRefresh: NSDate)->String {
        let lastUpdateSeconds = -1 * Int(lastRefresh.timeIntervalSinceNow)
        let lastUpdateMinutes = Int(lastUpdateSeconds / 60)
        let lastUpdateHours = Int(lastUpdateMinutes / 60)
        let lastUpdateDays = Int(lastUpdateHours / 24)
        let lastUpdateWeeks = Int(lastUpdateDays / 7)
        let lastUpdateYears = Int(lastUpdateWeeks / 52)
        
        if lastUpdateYears == 1 {
            return "Last refresh 1 year ago"
        } else if lastUpdateYears > 1 {
            return "Last refresh " + String(lastUpdateYears) + " years ago"
        } else if lastUpdateWeeks == 1 {
            return "Last refresh 1 week ago"
        } else if lastUpdateWeeks > 1 {
            return "Last refresh " + String(lastUpdateWeeks) + " weeks ago"
        } else if lastUpdateDays == 1 {
            return "Last refresh 1 day ago"
        } else if lastUpdateDays > 1 {
            return "Last refresh " + String(lastUpdateDays) + " days ago"
        } else if lastUpdateHours == 1 {
            return "Last refresh 1 hour ago"
        } else if lastUpdateHours > 1 {
            return "Last refresh " + String(lastUpdateHours) + " hours ago"
        } else if lastUpdateMinutes == 1 {
            return "Last refresh 1 minute ago"
        } else if lastUpdateMinutes > 1 {
            return "Last refresh " + String(lastUpdateMinutes) + " minutes ago"
        } else if lastUpdateSeconds == 1 {
            return "Last refresh 1 second ago"
        } else {
            return "Last refresh " + String(lastUpdateSeconds) + " seconds ago"
        }
    }
    
    func instanciateCell(index :NSIndexPath, tableView: UITableView) -> UITableViewCell{
        if index.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsHeaderTableViewCell", forIndexPath: index) as! NewsHeaderTableViewCell
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let lastDatabaseUpdate = defaults.objectForKey(ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT) as? NSDate {
                
                if refreshLabelTimer != nil {
                    refreshLabelTimer?.invalidate()
                    refreshLabelTimer = nil
                }
                
                refreshLabelTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(NewsTableViewController.updateRefreshLabel), userInfo: cell.newsLastRefreshLabel, repeats: true)
                
                cell.newsLastRefreshLabel.text = getLastRefreshString(lastDatabaseUpdate)
                
            } else {
                cell.newsLastRefreshLabel.text = ""
            }
            
            return cell as UITableViewCell
            
        } else if index.row == 1 && self.filteredAnnouncements.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoAnnouncementsTableViewCell", forIndexPath: index)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsTableViewCell", forIndexPath: index) as! NewsTableViewCell
            cell.titleLabel.text = self.filteredAnnouncements[index.row - 1].Title
            cell.descLabel.text = self.filteredAnnouncements[index.row - 1].Content
            return cell as UITableViewCell
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = instanciateCell(indexPath, tableView: tableView)
        
        
        
        return cell
        // Configure the cell...
        

    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NewsTableViewSegue"
        {
            if let destinationVC = segue.destinationViewController as? NewsViewController{
                let index = self.tableView.indexPathForSelectedRow!
                destinationVC.news = self.filteredAnnouncements[index.row - 1]
            }
        }
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        if let _ = self.slideMenuController() {
            self.slideMenuController()?.openLeft()
        }
    }
}
