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
    var events : Results<EventEntry>?
    var eventsDays = EventConferenceDay.getAll();
    var eventsRooms = EventConferenceRoom.getAll();
    var eventsTracks = EventConferenceTrack.getAll();
    var eventByDays = [Results<EventEntry>]()
    var eventByRooms = [Results<EventEntry>]()
    var eventByTracks = [Results<EventEntry>]()
    var filteredEvent = [EventEntry]()
    var eventByType = ""
    var eventTypeKey = ""
    var lastUpdate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rateApp();
        self.searchController.searchBar.showsScopeBar = false;
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.tintColor = UIColor.white;
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 120.0;
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 100.0;
        self.tableView.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        self.searchController.searchBar.scopeButtonTitles = ["Day", "Room", "Track"]
        self.refreshControl?.addTarget(self, action: #selector(EventTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.clear
    }
    
    func rateApp() {
        let rate = RateMyApp.sharedInstance
        rate.appID = "1112547322"
        rate.trackAppUsage()
    }
    
    // Pull to refresh function
    func refresh(_ sender:AnyObject) {
        ApiManager.sharedInstance.updateAllEntities(false, completion: {(isDataUpdated: Bool) in
            if isDataUpdated {
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        tableView.reloadData()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var eventNumber = 1;
        if searchController.isActive && searchController.searchBar.text != "" {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredEvent.count
        }
        var eventsInSection = Results<EventEntry>?(nilLiteral: ());
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
    
    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) ->CALayer {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        return border;
    }
    
    func createCellCustom(_ frame: CGRect) -> UIView{
        
        let whiteRoundedCornerView = UIView(frame: frame)
        whiteRoundedCornerView.backgroundColor = UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        whiteRoundedCornerView.layer.masksToBounds = false
        return whiteRoundedCornerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventTableViewCell
        let event: EventEntry
        if searchController.isActive && searchController.searchBar.text != "" {
            event = self.filteredEvent[(indexPath as NSIndexPath).row]
        } else {
            cell.eventDayLabel.isHidden = true;
            
            if cell.eventDayLabelHeightConstraint != nil {
                cell.eventDayLabelHeightConstraint!.isActive = true
            } else {
                cell.eventDayLabelHeightConstraint = NSLayoutConstraint(item: cell.eventDayLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
                cell.addConstraint(cell.eventDayLabelHeightConstraint!)
            }
            
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
        if searchController.isActive && searchController.searchBar.text != "" {
            if let eventDay = EventEntry.getDayByEventId(event.ConferenceDayId) {
                cell.eventDayLabel.isHidden = false;
                cell.eventDayLabel.text = eventDay.Name + " – " + dayOfWeekStringFromDateString(eventDay.Date);
                
                if cell.eventDayLabelHeightConstraint != nil {
                    cell.eventDayLabelHeightConstraint!.isActive = false
                }
            }
        }
        let formatedStartTime = (event.StartTime).characters.split{$0 == ":"}.map(String.init)
        let formatedDuration = (event.Duration).characters.split{$0 == ":"}.map(String.init)
        cell.eventNameLabel.text = event.Title
        
        if event.SubTitle.isEmpty {
            if cell.eventSubNameLabelHeightConstraint != nil {
                cell.eventSubNameLabelHeightConstraint!.isActive = true
            } else {
                cell.eventSubNameLabelHeightConstraint = NSLayoutConstraint(item: cell.eventSubNameLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
                cell.addConstraint(cell.eventSubNameLabelHeightConstraint!)
            }
        } else {
            if cell.eventSubNameLabelHeightConstraint != nil {
                cell.eventSubNameLabelHeightConstraint!.isActive = false
            }
            cell.eventSubNameLabel.text = event.SubTitle
        }
        cell.eventDateLabel.text = "Starting at " + formatedStartTime[0] + ":" + formatedStartTime[1]
        if let room = EventConferenceRoom.getById(event.ConferenceRoomId) {
            cell.eventRoomLabel.text = "in " + room.Name
        } else {
            cell.eventRoomLabel.text = "n/a"
        }
        cell.eventDurationLabel.text = "for " + formatedDuration[0] + " hour(s) " + formatedDuration[1] + " minute(s)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //if event.IsDeviatingFromConBook != "0" {
        //    cell.eventDateLabel.textColor = UIColor.orangeColor()
        //    cell.eventDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        //}
        cell.tintColor = UIColor.white
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Day") {
        filteredEvent = [];
        for events in  self.eventByDays {
            let eventsAsArray = Array(events)
            let searchPredicate = NSPredicate(format: "Title contains[c] %@", searchText)
            let results = (eventsAsArray as NSArray).filtered(using: searchPredicate);
            self.filteredEvent.append(contentsOf: results as! [EventEntry])
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionName = "";
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! EventHeaderCellTableViewCell
        if searchController.isActive && searchController.searchBar.text != "" {
            headerCell.headerCellLabel.text = "Results for : " + searchController.searchBar.text!;
            return headerCell;
        }
        sectionName = eventsDays![section].Name + "\n" + dayOfWeekStringFromDateString(self.eventsDays![section].Date);
        switch self.searchController.searchBar.selectedScopeButtonIndex {
            
        case 0:
            if (sectionName != "") {
                headerCell.headerCellLabel.text = sectionName;
            }
            else {
                headerCell.headerCellLabel.text = self.eventsDays![section].Name;
            }
        case 1:
            headerCell.headerCellLabel.text = self.eventsRooms![section].Name;
        case 2:
            headerCell.headerCellLabel.text = self.eventsTracks![section].Name;
        default:
            if (sectionName != "") {
                headerCell.headerCellLabel.text = sectionName;
            }
            else {
                headerCell.headerCellLabel.text = self.eventsDays![section].Name;
            }
        }
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.tableView.reloadData()
    }

    func dayOfWeekStringFromDateString(_ dateString: String)->String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        if let eventDate = dateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE dd MMMM"
            return dateFormatter.string(from: eventDate)
        }
        return dateString
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EventTableViewSegue"
        {
            if let destinationVC = segue.destination as? EventViewController{
                let indexPath = self.tableView.indexPathForSelectedRow!
                if searchController.isActive && searchController.searchBar.text != "" {
                    destinationVC.event = self.filteredEvent[(indexPath as NSIndexPath).row]
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
    
    @IBAction func openMenu(_ sender: AnyObject) {
        if let _ = self.slideMenuController() {
            self.slideMenuController()?.openLeft()
        }
    }
    
}
