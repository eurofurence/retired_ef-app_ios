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
    var annoucements = Results<Announcement>?();
    var filteredAnnouncements : [Announcement] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsTableViewController.notificationRefresh(_:)),name:"reloadData", object: nil)
        self.annoucements = Announcement.getAll();
        self.tableView.backgroundColor = UIColor.blackColor();
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension;
        self.refreshControl?.addTarget(self, action: #selector(DealerTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // Pull to refresh function
    func refresh(sender:AnyObject) {
        ApiManager.sharedInstance.updateAllEntities(false, completion: {(isDataUpdated: Bool) in
            if isDataUpdated {
                self.updateAnnouncements();
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
    
    func updateAnnouncements() {
        self.annoucements = Announcement.getAll();
        self.filteredAnnouncements = [];
        for announcement in annoucements! {
            let fromDate = NSDate.dateFromISOString(announcement.ValidFromDateTimeUtc);
            let untilDate = NSDate.dateFromISOString(announcement.ValidUntilDateTimeUtc);
            let currentDate = NSDate();
            if ((fromDate <= currentDate) && (untilDate >= currentDate)) {
                self.filteredAnnouncements.append(announcement);
            }
        }
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
        return (self.filteredAnnouncements.count + 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateAnnouncements();
        self.tableView.reloadData();
        
    }
    
    func instanciateCell(index :NSIndexPath, tableView: UITableView) -> UITableViewCell{
        if (index.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsHeaderTableViewCell", forIndexPath: index) as! NewsHeaderTableViewCell
            if (self.filteredAnnouncements.count == 0) {
               cell.newsHeaderLabel.text = "No announcement available";   
            }
            return cell as UITableViewCell;
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsTableViewCell", forIndexPath: index) as! NewsTableViewCell
            cell.titleLabel.text = self.filteredAnnouncements[index.row - 1].Title;
            cell.descLabel.text = self.filteredAnnouncements[index.row - 1].Content;
            return cell as UITableViewCell;
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = instanciateCell(indexPath, tableView: tableView);
        
        
        
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
