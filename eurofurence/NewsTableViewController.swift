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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //schemaConfigRealm()
        self.annoucements = Announcement.getAll();
        self.tableView.backgroundColor = UIColor.blackColor();
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension;
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.annoucements!.count + 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.annoucements = Announcement.getAll();
        self.tableView.reloadData()
        
    }
    
    func createCellCustom() -> UIView{
        let whiteRoundedCornerView = UIView(frame: CGRectMake(5,10,self.view.bounds.width-10,200))
        whiteRoundedCornerView.backgroundColor = UIColor(red: 22/255.0, green: 49/255.0, blue: 68/255.0, alpha: 1.0)
        whiteRoundedCornerView.layer.masksToBounds = false
        return whiteRoundedCornerView
    }
    
    func instanciateCell(index :NSIndexPath, tableView: UITableView) -> UITableViewCell{
        if (index.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsHeaderTableViewCell", forIndexPath: index)
            return cell as UITableViewCell;
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsTableViewCell", forIndexPath: index) as! NewsTableViewCell
            cell.tintColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.blackColor();
            cell.contentView.backgroundColor=UIColor.blackColor()
            let whiteRoundedCornerView = createCellCustom()
            cell.contentView.addSubview(whiteRoundedCornerView)
            cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
            cell.titleLabel.text = self.annoucements![index.row - 1].Title;
            cell.descLabel.text = self.annoucements![index.row - 1].Content;
            return cell as UITableViewCell;
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = instanciateCell(indexPath, tableView: tableView);
        
        
        
        return cell
        // Configure the cell...
        

    }
    
    func schemaConfigRealm() {
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            deleteRealmIfMigrationNeeded: true,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                if (oldSchemaVersion < 2) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
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
                destinationVC.news = self.annoucements![index.row - 1]
            }
        }
    }
    
}
