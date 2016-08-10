//
//  InfoTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 17/05/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import RealmSwift

class InfoTableViewController: UITableViewController {
    var infoGroup = InfoGroup.getAll();
    var sortedInfos = [String : [Info]]();
    var sortedKeys = [String]();
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func sortedInfosGroup() {
        self.sortedInfos = [String : [Info]]();
        self.sortedKeys = [String]();
        if let unwrapedInfoGroup = infoGroup {
            for currentInfoGroup in unwrapedInfoGroup {
                if let infoList = Info.getByGroupId(currentInfoGroup.Id) {
                    var infoListAsArray = [Info]();
                    for info in infoList {
                        infoListAsArray.append(info);
                    }
                    sortedKeys.append(currentInfoGroup.Name);
                    sortedInfos.updateValue(infoListAsArray, forKey: currentInfoGroup.Name)
                }
            }
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        sortedInfosGroup();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sortedInfos.count;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = self.sortedKeys[section];
        if let infos = self.sortedInfos[key] {
            return (infos.count)
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        let key = self.sortedKeys[indexPath.section];
        if let infos = self.sortedInfos[key] {
            cell.textLabel!.text = infos[indexPath.row].Title;
        }
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return sortedKeys[section]
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        headerView.backgroundColor = UIColor.grayColor()
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
        headerString.text = self.sortedKeys[section]
        headerString.textColor = UIColor.whiteColor()
        headerView .addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(InfoTableViewController.sectionHeaderTapped(_:)))
        headerView .addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)
        /**
         var indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
         if (indexPath.row == 0) {
         
         //var collapsed = arrayForBool.objectAtIndex(indexPath.section).boolValue
         //collapsed       = !collapsed;
         
         //arrayForBool.replaceObjectAtIndex(indexPath.section, withObject: collapsed)
         //reload specific section animated
         var range = NSMakeRange(indexPath.section, 1)
         var sectionToReload = NSIndexSet(indexesInRange: range)
         self.tableView .reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
         }
         **/
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
        if segue.identifier == "infosListToViewSegue" {
            if let destinationVC = segue.destinationViewController as? InfoViewController {
                let indexPath = self.tableView.indexPathForSelectedRow!
                let key = self.sortedKeys[indexPath.section];
                if let infos = self.sortedInfos[key] {
                    destinationVC.info = infos[indexPath.row];
                }
            }
        }
    }
    @IBAction func openMenu(sender: AnyObject) {
        if let _ = self.slideMenuController() {
            self.slideMenuController()?.openLeft()
        }
    }
    
    
}
