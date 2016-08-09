//
//  DealerViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 24/06/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DealerViewController: UIViewController {
    /// Higher numbers zoom out farther
    static var MAP_SEGMENT_ZOOM = CGFloat(8.0)
    
    var dealer = Dealer();
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistShortDescription: UILabel!
    @IBOutlet weak var aboutArtist: UILabel!
    @IBOutlet weak var artPreviewImage: UIImageView!
    @IBOutlet weak var artPreviewCaption: UILabel!
    @IBOutlet weak var aboutArt: UILabel!
    @IBOutlet weak var dealersDenMapImage: UIImageView!
    
    func canRotate()->Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.tabBarController?.tabBar.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        
        if let  artistImageId = self.dealer.ArtistImageId {
            self.artistImage.image = ImageManager.sharedInstance.retrieveFromCache(artistImageId, imagePlaceholder: UIImage(named: "defaultAvatar"))
        }
        else {
            self.artistImage.image = UIImage(named: "defaultAvatar")!;
        }
        
        self.artistName.text = self.dealer.AttendeeNickname;
        
        let shortDescription = self.dealer.ShortDescription!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringShortDescription = shortDescription.joinWithSeparator("\n");
        if (finalStringShortDescription == "") {
            self.artistShortDescription.text = "N/A"
        }
        else {
            self.artistShortDescription.text = finalStringShortDescription;
        }
        self.artistShortDescription.sizeToFit();
        
        let aboutArtist = self.dealer.AboutTheArtistText!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringAboutArtist = aboutArtist.joinWithSeparator("\n");
        if (finalStringAboutArtist == "") {
            self.aboutArtist.text = "N/A"
        }
        else {
            self.aboutArtist.text = finalStringAboutArtist;
        }
        self.aboutArtist.sizeToFit();
        
        if let artPreviewImageId =   self.dealer.ArtPreviewImageId {
            self.artPreviewImage.image = ImageManager.sharedInstance.retrieveFromCache(artPreviewImageId, imagePlaceholder: UIImage(named: "ef"))
        }
        else {
            self.artPreviewImage.image = UIImage(named: "ef")!;
        }
        
        let artPreviewCaption = self.dealer.ArtPreviewCaption!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringArtPreviewCaption = artPreviewCaption.joinWithSeparator("\n");
        if (finalStringArtPreviewCaption == "") {
            self.artPreviewCaption.text = "N/A"
        }
        else {
            self.artPreviewCaption.text = finalStringArtPreviewCaption;
        }
        self.artPreviewCaption.sizeToFit();
        
        let AboutArt = self.dealer.AboutTheArtText!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringAboutArt = AboutArt.joinWithSeparator("\n");
        if (finalStringAboutArt == "") {
            self.aboutArt.text = "N/A"
        }
        else {
            self.aboutArt.text = finalStringAboutArt;
        }
        self.aboutArt.sizeToFit();
        
        if let mapEntry = MapEntry.getByTargetId(self.dealer.Id), let map = Map.getById(mapEntry.MapId), let mapImage = ImageManager.sharedInstance.retrieveFromCache(map.ImageId!), let relativeX = Double.init(mapEntry.RelativeX), let relativeY = Double.init(mapEntry.RelativeY), let relativeTapRadius = Double(mapEntry.RelativeTapRadius) {
            
            let ratio = self.dealersDenMapImage.bounds.width / self.dealersDenMapImage.bounds.height
            
            let radius = CGFloat(relativeTapRadius) * mapImage.size.height
            let segmentHeight = radius * DealerViewController.MAP_SEGMENT_ZOOM
            let segmentWidth = segmentHeight * ratio
            
            
            let absoluteX = CGFloat(relativeX/100) * mapImage.size.width
            let absoluteY = CGFloat(relativeY/100) * mapImage.size.height
            
            let offsetX = min(max(0.0, absoluteX - segmentWidth / 2.0), mapImage.size.width - segmentWidth)
            let offsetY = min(max(0.0, absoluteY - segmentHeight / 2.0), mapImage.size.height - segmentHeight)
            
            if let croppedMap = CGImageCreateWithImageInRect(mapImage.CGImage, CGRect(x: offsetX, y: offsetY, width: segmentWidth, height: segmentHeight)) {
            
                // Initialise the context
                let size = CGSize(width: segmentWidth, height: segmentHeight)
                let opaque = true
                let scale: CGFloat = 0
                UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
                let context = UIGraphicsGetCurrentContext()
                
                // Draw the map segment
                UIImage(CGImage: croppedMap).drawInRect(CGRect(origin: CGPoint.zero, size: size))
                
                CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
                CGContextSetLineWidth(context, 2.0)
                
                let highlightRect = CGRect(x: absoluteX - offsetX - radius, y: absoluteY - offsetY - radius, width: radius * 2, height: radius * 2)
                CGContextStrokeEllipseInRect(context, highlightRect)
                
                // Drawing complete, retrieve the finished image and cleanup
                self.dealersDenMapImage.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
