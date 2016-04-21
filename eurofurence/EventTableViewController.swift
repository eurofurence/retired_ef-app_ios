//
//  EventTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 05/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import RealmSwift

class EventTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {
    let searchController = UISearchController(searchResultsController: nil)
    var events = EventEntry.getAll();
    var filteredEvent = Results<EventEntry>?()
    var eventByType = ""
    var eventTypeKey = ""
    var lastUpdate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        //self.searchController.searchBar.barTintColor = UIColor(red: 0/255.0, green: 98/255.0, blue: 87/255.0, alpha: 0.5);
        self.searchController.searchBar.tintColor = UIColor.whiteColor();
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        switch self.eventByType {
        case "":
            self.searchController.searchBar.selectedScopeButtonIndex = 0;
            self.events = EventEntry.getAll();
        case "Room":
            self.searchController.searchBar.selectedScopeButtonIndex = 1;
            self.events = EventEntry.getByRoomId(self.eventTypeKey);
        case "Track":
            self.searchController.searchBar.selectedScopeButtonIndex = 2;
            self.events = EventEntry.getByTrackId(self.eventTypeKey);
        case "Day":
            self.searchController.searchBar.selectedScopeButtonIndex = 3;
            self.events = EventEntry.getByDayId(self.eventTypeKey);
        default:
            break
        }
        self.tableView.reloadData()

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let lastChange = dateFormatter.stringFromDate(self.lastUpdate);
        let updateString = "Last Updated at " + lastChange;
        self.refreshControl!.attributedTitle = NSAttributedString(string: updateString)
        ApiManager.sharedInstance.get(ObjectFromString.sharedInstance.instanciate("EventEntry") as! Object, objectName: "EventEntry",  completion: {
                    (result: String) in
                    self.lastUpdate = NSDate()
                    self.refreshControl!.attributedTitle = NSAttributedString(string: updateString)
                    self.events = EventEntry.getAll();
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
            
        });
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return self.filteredEvent!.count
        }
         return self.events!.count;
       
    }

    func createCellCustom() -> UIView{
    let whiteRoundedCornerView = UIView(frame: CGRectMake(5,10,self.view.bounds.width-10,118))
    whiteRoundedCornerView.backgroundColor = UIColor(red: 0/255.0, green: 120/255.0, blue: 106/255.0, alpha: 1.0)
    whiteRoundedCornerView.layer.masksToBounds = false
        return whiteRoundedCornerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        let event: EventEntry
        if searchController.active && searchController.searchBar.text != "" {
             event = self.filteredEvent![indexPath.row]
        } else {
             event = self.events![indexPath.row]
        }
        
        //cell.contentView.backgroundColor=UIColor(red: 2/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1.0)
        let whiteRoundedCornerView = createCellCustom()
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let separators = NSCharacterSet(charactersInString: "–")
        let formatedTitle = (event.Title).componentsSeparatedByCharactersInSet(separators)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        cell.eventNameLabel.text = formatedTitle[0]
        if (formatedTitle.count > 1) {
            cell.eventSubNameLabel.text = "| " + formatedTitle[1]
        }
        else {
            cell.eventSubNameLabel.text = ""
        }
        cell.eventDateLabel.text = " " + formatedStartTime[0] + "h" + formatedStartTime[1]
        cell.eventDurationLabel.text = " "  + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " min"
        cell.eventRoomLabel.text = " " + room!.Name
        cell.eventDayLabel.text = " | " + day!.Name
        cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        cell.tintColor = UIColor.whiteColor()

        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredEvent = EventEntry.getByTitle(searchText);
        tableView.reloadData()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EventTableViewSegue"
        {
            if let destinationVC = segue.destinationViewController as? EventViewController{
                let index = self.tableView.indexPathForSelectedRow!
                destinationVC.event = self.events![index.row]
            }
        }
    }

}
