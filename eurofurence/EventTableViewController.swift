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
    var events = Results<EventEntry>?()
    var eventsDays = EventConferenceDay.getAll();
    var eventsRooms = EventConferenceRoom.getAll();
    var eventsTracks = EventConferenceTrack.getAll();
    var eventByDays = [Results<EventEntry>]()
    var eventByRooms = [Results<EventEntry>]()
    var eventByTracks = [Results<EventEntry>]()
    var filteredEvent = Results<EventEntry>?()
    var eventByType = ""
    var eventTypeKey = ""
    var lastUpdate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.tintColor = UIColor.whiteColor();
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        self.searchController.searchBar.scopeButtonTitles = ["Day", "Room", "Track"]
        self.refreshControl?.addTarget(self, action: #selector(EventTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.backgroundColor = UIColor.clearColor()
    }
    
    // Pull to refresh function
    func refresh(sender:AnyObject)
    {
        let objects = [ConfigManager.sharedInstance.eventConferenceDay, ConfigManager.sharedInstance.eventConferenceRoom, ConfigManager.sharedInstance.eventConferenceTrack]
        var updatedObjects = 0;
        for object in objects {
            if let objectInstance = ObjectFromString.sharedInstance.instanciate(object) {
                ApiManager.sharedInstance.get(objectInstance as! Object, objectName: object) {
                    (result: String) in
                    updatedObjects += 1;
                    if (updatedObjects == (objects.count - 1)) {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        return;
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        for eventDay in eventsDays! {
            self.eventByDays.append(EventEntry.getByDayId(eventDay.Id)!);
        }
        for eventRoom in eventsRooms! {
            self.eventByRooms.append(EventEntry.getByRoomId(eventRoom.Id)!);
        }
        for eventTrack in eventsTracks! {
            self.eventByTracks.append(EventEntry.getByTrackId(eventTrack.Id)!);
        }
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
    
    /*
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
     */
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var eventNumber = 1;
        if searchController.active && searchController.searchBar.text != "" {
            return eventNumber;
        }
        
        switch self.searchController.searchBar.selectedScopeButtonIndex {
        case 0:
            eventNumber = (eventsDays?.count)!
        case 1:
            eventNumber = (eventsRooms?.count)!
        case 2:
            eventNumber = (eventsTracks?.count)!
        default:
            break
        }
        return eventNumber
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return self.filteredEvent!.count
        }
        var eventsInSection = Results<EventEntry>?();
        switch self.searchController.searchBar.selectedScopeButtonIndex {
        case 0:
            eventsInSection =  EventEntry.getByDayId(eventsDays![section].Id)
        case 1:
            eventsInSection =  EventEntry.getByRoomId(eventsRooms![section].Id)
        case 2:
            eventsInSection =  EventEntry.getByTrackId(eventsTracks![section].Id)
        default:
            break
        }
        return eventsInSection!.count;
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return "Search results for : " + searchController.searchBar.text!;
        }
        
        
        switch self.searchController.searchBar.selectedScopeButtonIndex {
        case 0:
            if section < eventsDays!.count {
                return eventsDays![section].Name
            }
        case 1:
            if section < eventsRooms!.count {
                return eventsRooms![section].Name
            }
        case 2:
            if section < eventsTracks!.count {
                return eventsTracks![section].Name
            }
        default:
            break
        }
        
        return nil
    }
    
    private func addBorderUtility(x x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) ->CALayer {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        return border;
    }
    
    func createCellCustom(frame: CGRect) -> UIView{
        
        let whiteRoundedCornerView = UIView(frame: frame)
        whiteRoundedCornerView.backgroundColor = UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
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
            switch self.searchController.searchBar.selectedScopeButtonIndex {
            case 0:
                event = self.eventByDays[indexPath.section][indexPath.row]
            case 1:
                event = self.eventByRooms[indexPath.section][indexPath.row]
            case 2:
                event = self.eventByTracks[indexPath.section][indexPath.row]
            default:
                event = self.eventByDays[indexPath.section][indexPath.row]
            }
            
        }
        let frame = CGRectMake(5,10,self.view.bounds.width-10,118);
        //cell.contentView.backgroundColor=UIColor(red: 2/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1.0)
        let whiteRoundedCornerView = createCellCustom(frame)
        let whiteBorder = addBorderUtility(x: 0, y: frame.height - 1.0, width: frame.width, height: 1.0, color: UIColor(red: 86/255.0, green: 87/255.0, blue: 89/255.0, alpha: 1.0))
        cell.backgroundColor = UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        cell.layer.addSublayer(whiteBorder)
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        let separators = NSCharacterSet(charactersInString: "–")
        let formatedTitle = (event.Title).componentsSeparatedByCharactersInSet(separators)
        let day = EventConferenceDay.getById(event.ConferenceDayId)
        let room = EventConferenceRoom.getById(event.ConferenceRoomId)
        cell.eventNameLabel.text = formatedTitle[0]
        cell.eventDateLabel.text = " " + formatedStartTime[0] + "h" + formatedStartTime[1]
        cell.eventDurationLabel.text = " "  + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " min"
        cell.eventRoomLabel.text = " " + room!.Name
        cell.eventDayLabel.text = " | " + day!.Name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
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
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! EventHeaderCellTableViewCell
        
        switch self.searchController.searchBar.selectedScopeButtonIndex {
        case 0:
            headerCell.headerCellLabel.text = self.eventsDays![section].Name;
        case 1:
            headerCell.headerCellLabel.text = self.eventsRooms![section].Name;
        case 2:
            headerCell.headerCellLabel.text = self.eventsTracks![section].Name;
        default:
            headerCell.headerCellLabel.text = self.eventsDays![section].Name;
        }
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.tableView.reloadData()
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
                let indexPath = self.tableView.indexPathForSelectedRow!
                if searchController.active && searchController.searchBar.text != "" {
                    destinationVC.event = self.filteredEvent![indexPath.row]
                } else {
                    switch self.searchController.searchBar.selectedScopeButtonIndex {
                    case 0:
                        destinationVC.event = self.eventByDays[indexPath.section][indexPath.row]
                    case 1:
                        destinationVC.event = self.eventByRooms[indexPath.section][indexPath.row]
                    case 2:
                        destinationVC.event = self.eventByTracks[indexPath.section][indexPath.row]
                    default:
                        destinationVC.event = self.eventByDays[indexPath.section][indexPath.row]
                    }
                    //destinationVC.event = self.events![index.row]
                }
                
            }
        }
    }
    
}
