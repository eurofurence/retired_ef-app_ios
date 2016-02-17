//
//  EventTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 05/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class Event {
    var name: String = ""
    var beginDate: String = ""
    var endDate: String = ""
    var room: String = ""

   
    init(name: String, beginDate: String, endDate: String, room: String) {
        self.name = name
        self.beginDate = beginDate;
        self.endDate = endDate;
        self.room = room;
        
    }
}

class EventTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {
    let searchController = UISearchController(searchResultsController: nil)
    var events = [Event]()
    
    func loadSampleEvents() {
        let event1 = Event(name: "Event1", beginDate: "10:30 10/20", endDate: "10:30 10/20", room: "366")
        
        let event2 = Event(name: "Event2", beginDate: "10:30 10/20", endDate: "10:30 10/20", room: "366")
        
        let event3 = Event(name: "Event3", beginDate: "10:30 10/20", endDate: "10:30 10/20", room: "366")
        
        self.events = [event1, event2, event3];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleEvents();
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ["All", "Today", "Now"]
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 0.5);
        self.searchController.searchBar.tintColor = UIColor.whiteColor();
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {

        
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count;
    }

    func createCellCustom() -> UIView{
    let whiteRoundedCornerView = UIView(frame: CGRectMake(5,10,self.view.bounds.width-10,190))
    whiteRoundedCornerView.backgroundColor = UIColor(red: 0/255.0, green: 120/255.0, blue: 106/255.0, alpha: 1.0)
    whiteRoundedCornerView.layer.masksToBounds = false
    whiteRoundedCornerView.layer.shadowOpacity = 1.55;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(1, 0);
    whiteRoundedCornerView.layer.shadowColor = UIColor(red: 53/255.0, green: 143/255.0, blue: 185/255.0, alpha: 1.0).CGColor
    whiteRoundedCornerView.layer.cornerRadius = 3.0
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, -1)
    whiteRoundedCornerView.layer.shadowOpacity = 0.5
        return whiteRoundedCornerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        let event = self.events[indexPath.row]
        cell.contentView.backgroundColor=UIColor.clearColor()
        
        let whiteRoundedCornerView = createCellCustom()
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        cell.eventNameLabel.text = event.name;
        cell.eventDateLabel.text = "Tuesday - 10h00";
        cell.eventRoomLabel.text = "Location : " + event.room;
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
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

}
