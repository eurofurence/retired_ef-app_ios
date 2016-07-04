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
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
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
        let baseImage = ConfigManager.sharedInstance.apiBaseUrl +  "ImageData/"
        if let url =   self.dealers![indexPath.row].ArtistThumbnailImageId {             
        let downloadUrl = NSURLRequest(URL:NSURL(string: baseImage + url)!)
            let avatarImage = UIImage(named: "defaultAvatar")!.af_imageRoundedIntoCircle()
            let cachedAvatarImage = imageCache.imageForRequest(
                downloadUrl,
                withAdditionalIdentifier: "circle"
            )
            if ((cachedAvatarImage) == nil) {
                self.imageCache.addImage(
                    avatarImage,
                    forRequest: downloadUrl,
                    withAdditionalIdentifier: "circle"
                )
            }
            cell.artistDealerImage.af_setImageWithURLRequest(downloadUrl, placeholderImage: avatarImage, filter: CircleFilter(), imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false)

            //cell.artistDealerImage.af_setImageWithURL(downloadUrl);
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
