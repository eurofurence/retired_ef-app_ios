//
//  InfoCollectionViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 16/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "cell"


class InfoCollectionViewController: UICollectionViewController {
var sectionMenu = InfoGroup.getAll();
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sectionMenu = InfoGroup.getAll();

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        collectionView!.registerClass(InfoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.
    }
    
    func canRotate()->Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return  (sectionMenu?.count)!
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 16, height: 60)
    }

    func createCollectionCellCustom() -> UIView{
        let whiteRoundedCornerView = UIView(frame: CGRectMake(5,10,(collectionView!.frame.size.width)-10,110))
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
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! InfoCollectionViewCell
        cell.cellTitle.text = sectionMenu![indexPath.row].Name;
    
        // Configure the cell
        cell.contentView.backgroundColor=UIColor.clearColor()
        
        //let whiteRoundedCornerView = createCollectionCellCustom()
        //cell.contentView.addSubview(whiteRoundedCornerView)
        //cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "infoCatToListSegue"
        {
            if let destinationVC = segue.destinationViewController as? InfoTableViewController{
                let cell = sender as! InfoCollectionViewCell
                let index = self.collectionView?.indexPathForCell(cell)
                destinationVC.infoGroup = sectionMenu![index!.row]
            }
        }
    }

}