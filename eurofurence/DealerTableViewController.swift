//
//  DealerTableViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 17/06/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import AlamofireImage

class DealerTableViewController: UITableViewController {
    var dealers = Dealer.getAll();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        self.refreshControl?.addTarget(self, action: #selector(DealerTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // Pull to refresh function
    func refresh(sender:AnyObject) {
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
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.dealers!.count)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dealers = Dealer.getAll();
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DealersTableViewCell", forIndexPath: indexPath) as! DealersTableViewCell
        cell.displayNameDealerLabel!.text = self.dealers![indexPath.row].AttendeeNickname;
        if let subname = self.dealers![indexPath.row].DisplayName {
            cell.subnameDealerLabel!.text = subname;
        }
        cell.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        cell.shortDescriptionDealerLabel!.text = self.dealers![indexPath.row].ShortDescription;
        if let artistThumbnailImageId =   self.dealers![indexPath.row].ArtistThumbnailImageId {
            cell.artistDealerImage.image = ImageManager.sharedInstance.retrieveFromCache(artistThumbnailImageId, imagePlaceholder: UIImage(named: "defaultAvatar")!.af_imageRoundedIntoCircle())!.af_imageRoundedIntoCircle();
        }
        else {
            cell.artistDealerImage.image = UIImage(named: "defaultAvatar")!.af_imageRoundedIntoCircle();
        }
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DealerTableToDetailViewSegue"
        {
            if let destinationVC = segue.destinationViewController as? DealerViewController{
                let index = self.tableView.indexPathForSelectedRow!
                destinationVC.dealer = self.dealers![index.row]
            }
        }
    }
    
}
