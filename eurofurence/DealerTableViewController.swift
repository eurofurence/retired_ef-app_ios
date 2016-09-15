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
    var dealersWithSection = [String: [Dealer]]();
    var sortedKeys = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        self.refreshControl?.addTarget(self, action: #selector(DealerTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.sectionIndexColor = UIColor.white
    }
    
    func canRotate()->Bool {
        return true
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dealersWithSection.keys.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = sortedKeys[section];
        if let dealersWithLetter = dealersWithSection[key] {
            return (dealersWithLetter.count)
        }
        else {
            return 0
        }
    }
    
    func orderDealersAlphabeticaly() {
        if let unwrapedDealers = self.dealers {
            for dealer in unwrapedDealers {
                var dealerName: String?
                
                if let displayName = dealer.DisplayName , !displayName.isEmpty {
                    dealerName = displayName
                } else if let attendeeNickname = dealer.AttendeeNickname , !attendeeNickname.isEmpty {
                    dealerName = attendeeNickname
                }
                
                if let dealerName = dealerName {
                    let upperDealerName = dealerName.firstCharacterUpperCase();
                    let firstLetter = String(upperDealerName[upperDealerName.startIndex]);
                    if var dealersWithLetter = dealersWithSection[firstLetter]{
                        dealersWithLetter.append(dealer);
                        dealersWithSection.updateValue(dealersWithLetter, forKey: firstLetter)
                    }
                    else {
                        var initDealerNameArray = [Dealer]();
                        initDealerNameArray.append(dealer);
                        dealersWithSection.updateValue(initDealerNameArray, forKey: firstLetter)
                    }
                }
            }
            self.sortedKeys = dealersWithSection.keys.sorted();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dealersWithSection = [String: [Dealer]]();
        self.sortedKeys = [String]();
        self.dealers = Dealer.getAll();
        orderDealersAlphabeticaly();
        self.tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DealersTableViewCell", for: indexPath) as! DealersTableViewCell
        let dealer = self.dealersWithSection[sortedKeys[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
        
        
        if let dealerDisplayName = dealer.DisplayName , !dealerDisplayName.isEmpty {
            cell.displayNameDealerLabel!.text = dealer.DisplayName
            cell.subnameDealerLabel!.text = dealer.AttendeeNickname
        } else {
            cell.displayNameDealerLabel!.text = dealer.AttendeeNickname
            cell.subnameDealerLabel!.text = nil
        }
        
        cell.backgroundColor =  UIColor(red: 35/255.0, green: 36/255.0, blue: 38/255.0, alpha: 1.0)
        cell.shortDescriptionDealerLabel!.text = dealer.ShortDescription;
        if let artistThumbnailImageId =   dealer.ArtistThumbnailImageId {
            let optionalDealerImage = ImageManager.sharedInstance.retrieveFromCache(artistThumbnailImageId, imagePlaceholder: UIImage(named: "defaultAvatar"))
            if let dealerImage = optionalDealerImage {
                cell.artistDealerImage.image = dealerImage.af_imageRoundedIntoCircle().af_imageRoundedIntoCircle();
            }
            
        }
        else {
            cell.artistDealerImage.image = UIImage(named: "defaultAvatar")!.af_imageRoundedIntoCircle();
        }
        
        return cell
    }
    
    override func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return sortedKeys[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedKeys
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 68/255, green: 69/255, blue: 72/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.white //make the text white
        header.alpha = 0.8 //make the header transparent
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
        if segue.identifier == "DealerTableToDetailViewSegue"
        {
            if let destinationVC = segue.destination as? DealerViewController{
                let indexPath = self.tableView.indexPathForSelectedRow!
                destinationVC.dealer = self.dealersWithSection[sortedKeys[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
            }
        }
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        if let _ = self.slideMenuController() {
            self.slideMenuController()?.openLeft()
        }
    }
}
