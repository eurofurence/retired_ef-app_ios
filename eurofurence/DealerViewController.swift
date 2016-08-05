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
    @IBOutlet weak var artistThumbImageView: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistShortDesc: UILabel!
    @IBOutlet weak var aboutArtist: UILabel!
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var aboutArtLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.artistName.text = self.dealer.AttendeeNickname;
        
        let newlineChars = NSCharacterSet.newlineCharacterSet()
        let ShortDesc = self.dealer.ShortDescription!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringShortDesc = ShortDesc.joinWithSeparator("\n");
        if (finalStringShortDesc == "") {
            self.artistShortDesc.text = "N/A"
        }
        else {
            self.artistShortDesc.text = finalStringShortDesc;
        }
        
        self.artistShortDesc.sizeToFit();
        
        let AboutArtist = self.dealer.AboutTheArtistText!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringAboutArtist = AboutArtist.joinWithSeparator("\n");
        if (finalStringAboutArtist == "") {
            self.aboutArtist.text = "N/A"
        }
        else {
            self.aboutArtist.text = finalStringAboutArtist;
        }
        self.aboutArtist.sizeToFit();
        
        let AboutArt = self.dealer.AboutTheArtText!.utf16.split { newlineChars.characterIsMember($0) }.flatMap(String.init)
        let finalStringAboutArt = AboutArt.joinWithSeparator("\n");
        if (finalStringAboutArt == "") {
            self.aboutArtLabel.text = "N/A"
        }
        else {
            self.aboutArtLabel.text = finalStringAboutArt;
        }
        self.aboutArtLabel.sizeToFit();
        
        if let  artistThumbnailImageId = self.dealer.ArtistThumbnailImageId {
            self.artistThumbImageView.image = ImageManager.sharedInstance.retrieveFromCache(artistThumbnailImageId, imagePlaceholder: UIImage(named: "defaultAvatar"))
        }
        else {
            self.artistThumbImageView.image = UIImage(named: "defaultAvatar")!;
        }
        
        
        
        if let artPreviewImageId =   self.dealer.ArtPreviewImageId {
            self.artistThumbImageView.image = ImageManager.sharedInstance.retrieveFromCache(artPreviewImageId, imagePlaceholder: UIImage(named: "defaultAvatar"))
        }
        else {
            self.artImageView.image = UIImage(named: "defaultAvatar")!;
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
