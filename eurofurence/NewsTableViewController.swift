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
    var refreshLabelTimer: Timer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NewsTableViewController.notificationRefresh(_:)),name:NSNotification.Name(rawValue: "reloadData"), object: nil)
        self.annoucements = Announcement.getAll()
        self.tableView.backgroundColor = UIColor.black
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension;
        self.refreshControl?.addTarget(self, action: #selector(NewsTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Reset the application badge because all announcements can be assumed seen
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    // Pull to refresh function
    func refresh(_ sender:AnyObject) {
        ApiManager.sharedInstance.updateAllEntities(false, completion: {(isDataUpdated: Bool) in
            if isDataUpdated {
                self.updateAnnouncements()
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        })
    }
    
    func notificationRefresh(_ notification: Notification){
        DispatchQueue.main.async {
            self.updateAnnouncements()
            self.tableView.reloadData()
        }
    }
    
    func updateAnnouncements()->[String] {
        self.annoucements = Announcement.getAll()
        let oldAnnouncements = self.filteredAnnouncements
        var newAnnouncementIds: [String] = []
        self.filteredAnnouncements = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        for announcement in annoucements! {
            
            let currentDate = NSDate();
            let utcTimeZoneStr = formatter.stringFromDate(currentDate)
            
            // Check whether we are currently within the announcements validity time frame
            if let currentDateUtc = NSDate.dateFromISOString(utcTimeZoneStr),
                let fromDate = NSDate.dateFromISOString(announcement.ValidFromDateTimeUtc),
                let untilDate = NSDate.dateFromISOString(announcement.ValidUntilDateTimeUtc)
                , (fromDate.compare(currentDateUtc) != NSComparisonResult.OrderedDescending && untilDate.compare(currentDateUtc) != NSComparisonResult.OrderedAscending) {
                
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
    
    func notifyAnnouncements(_ announcementIds: [String]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if UserSettings<Bool>.NotifyOnAnnouncement.currentValue() {
            for announcementId in announcementIds {
                if let announcement = Announcement.getById(announcementId) {
                    let notification = UILocalNotification()
                    notification.alertBody = announcement.Title
                    notification.timeZone = TimeZone(abbreviation: "UTC")
                    if let announcementDate = Date.dateFromISOString(announcement.ValidFromDateTimeUtc) {
                        notification.fireDate = announcementDate
                    }
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.userInfo = ["Announcement.Id": announcement.Id ]
                    notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                    
                    UIApplication.shared.presentLocalNotificationNow(notification)
                }
            }
        } else if announcementIds.count > 0 {
            UIApplication.shared.applicationIconBadgeNumber = announcementIds.count
        }
        
        
        if let tabBarItem = self.navigationController?.tabBarItem , announcementIds.count > 0 {
            tabBarItem.badgeValue = String(announcementIds.count)
        }
    }
    
    func fetchAnnouncements(_ completion: @escaping (_ isSuccessful: Bool)->Void) {
        let defaults = UserDefaults.standard
        let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT) as? Date
        ApiManager.sharedInstance.updateEntity("Announcement", since: lastDatabaseUpdate, completion: { result, isSuccessful in
            completion(isSuccessful: isSuccessful)
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.filteredAnnouncements.count > 0 {
            return (self.filteredAnnouncements.count + 1)
        } else {
            return 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateAnnouncements();
        self.tableView.reloadData();
        if let tabBarItem = self.navigationController?.tabBarItem {
            tabBarItem.badgeValue = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        let defaults = UserDefaults.standard
        if let userInfo = refreshLabelTimer?.userInfo, let newsLastRefreshLabel = userInfo as? UILabel, let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT) as? Date {
            
            newsLastRefreshLabel.text = getLastRefreshString(lastDatabaseUpdate)
        }
    }
    
    func getLastRefreshString(_ lastRefresh: Date)->String {
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
    
    func instanciateCell(_ index :IndexPath, tableView: UITableView) -> UITableViewCell{
        if (index as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsHeaderTableViewCell", for: index) as! NewsHeaderTableViewCell
            
            let defaults = UserDefaults.standard
            if let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_LOCAL_DEFAULT) as? Date {
                
                if refreshLabelTimer != nil {
                    refreshLabelTimer?.invalidate()
                    refreshLabelTimer = nil
                }
                
                refreshLabelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NewsTableViewController.updateRefreshLabel), userInfo: cell.newsLastRefreshLabel, repeats: true)
                
                cell.newsLastRefreshLabel.text = getLastRefreshString(lastDatabaseUpdate)
                
            } else {
                cell.newsLastRefreshLabel.text = ""
            }
            
            return cell as UITableViewCell
            
        } else if (index as NSIndexPath).row == 1 && self.filteredAnnouncements.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NoAnnouncementsTableViewCell", for: index)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: index) as! NewsTableViewCell
            cell.titleLabel.text = self.filteredAnnouncements[(index as NSIndexPath).row - 1].Title
            cell.descLabel.text = self.filteredAnnouncements[(index as NSIndexPath).row - 1].Content
            return cell as UITableViewCell
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NewsTableViewSegue"
        {
            if let destinationVC = segue.destination as? NewsViewController{
                let index = self.tableView.indexPathForSelectedRow!
                destinationVC.news = self.filteredAnnouncements[(index as NSIndexPath).row - 1]
            }
        }
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        if let _ = self.slideMenuController() {
            self.slideMenuController()?.openLeft()
        }
    }
}
