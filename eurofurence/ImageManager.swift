//
//  ImageManager.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 04/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageManager {
    let baseImage = ConfigManager.sharedInstance.apiBaseUrl +  "ImageData/";
    let downloader = ConfigManager.sharedInstance.diskImageDownloader();
    static let sharedInstance = ImageManager();
    
    func cachingAllImages() {
        let dealers = Dealer.getAll();
        for dealer in dealers! {
            if (dealer.ArtistThumbnailImageId != nil) {
                cachingImage(dealer.ArtistThumbnailImageId!);
            }
            
        }
    }
    
    func cachingImage(imageId : String) {
        let URLRequest = NSURLRequest(URL: NSURL(string: self.baseImage + imageId)!)
        let filter = AspectScaledToFillSizeCircleFilter(size: CGSize(width: 100.0, height: 100.0))
        self.downloader.downloadImage(URLRequest: URLRequest, filter: filter) { response in
            if let image = response.result.value {
                let imageData = UIImageJPEGRepresentation(image,  1.0);
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let imagePath = paths.stringByAppendingPathComponent(imageId + ".jpg")
                
                if !imageData!.writeToFile(imagePath, atomically: false)
                {
                    print("Error with imageData on image caching manager")
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
                }
            }
        }
    }
    func retrieveFromCache(imageId: String) -> UIImage? {
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0
        {
            let dirPath = paths[0]
            if (dirPath != "") {
                let readPath = dirPath.stringByAppendingPathComponent(imageId + ".jpg");
                let image    = UIImage(contentsOfFile: readPath);
                return image;
            }
        }
        return nil;
    }
};