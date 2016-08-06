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
    
    override func viewWillAppear(animated: Bool) {
        
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
            self.artPreviewImage.image = ImageManager.sharedInstance.retrieveFromCache(artPreviewImageId, imagePlaceholder: UIImage(named: "defaultAvatar"))
        }
        else {
            self.artPreviewImage.image = UIImage(named: "defaultAvatar")!;
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
