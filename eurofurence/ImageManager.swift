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
    
    func cacheDealersImages() {
        let dealers = Dealer.getAll();
        //LoadingOverlay.sharedInstance.changeMessage("Caching images ...");
        //LoadingOverlay.sharedInstance.showOverlay()
        for dealer in dealers! {
            if (dealer.ArtistThumbnailImageId != nil) {
                cacheImage(dealer.ArtistThumbnailImageId!);
            }
            if (dealer.ArtistImageId != nil) {
                cacheImage(dealer.ArtistImageId!);
            }
            if (dealer.ArtPreviewImageId != nil) {
                cacheImage(dealer.ArtPreviewImageId!);
            }
        }
        
        //LoadingOverlay.sharedInstance.hideOverlay()
    }
    
    func cacheMapImages() {
        
    }
    
    func cacheAllImages() {
        cacheDealersImages();
        //LoadingOverlay.sharedInstance.hideOverlay();
    }
    
    func documentsPathWithFileName(fileName : String) -> String {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return documentsDirectoryPath.stringByAppendingPathComponent(fileName)
    }
    
    func deleteFromCache(imagePath: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch {
            print("Can not delete image");
        }
    }
    
    func cacheImage(imageId : String) {
        let URLRequest = NSURLRequest(URL: NSURL(string: self.baseImage + imageId)!)
        self.downloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value {
                let imageData = UIImageJPEGRepresentation(image,  1.0);
                let imagePath = self.documentsPathWithFileName(imageId + ".jpg")
                self.deleteFromCache(imagePath);
                if !imageData!.writeToFile(imagePath, atomically: false)
                {
                    print("Error with imageData on image caching manager")
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
                }
            }
        }
    }
    func retrieveFromCache(imageId: String, imagePlaceholder: UIImage?) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if paths.count > 0
        {
            let dirPath = paths[0]
            if (dirPath != "") {
                let readPath = dirPath.stringByAppendingPathComponent(imageId + ".jpg");
                if (readPath != "") {
                    let image = UIImage(contentsOfFile: readPath);
                    return image;
                }
                else {
                    cacheImage(imageId);
                    return retrieveFromCache(imageId, imagePlaceholder: imagePlaceholder)
                }
                
            }
        }
        return imagePlaceholder != nil ? imagePlaceholder : nil;
    }
};