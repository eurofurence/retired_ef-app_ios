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
    let dispatchGroup = dispatch_group_create();
    
    func dispatchEntity(entityId: String?) {
        if (entityId != nil) {
            dispatch_group_enter(self.dispatchGroup)
            cacheImage(entityId!) {
                (result: Bool) in
                dispatch_group_leave(self.dispatchGroup)
            };
        }
    }
    
    /// Get all dealers in the Realm Database to cache all images with cacheImage
    func cacheDealersImages() {
        let dealersOptional = Dealer.getAll();
        if let dealers = dealersOptional {
            LoadingOverlay.sharedInstance.changeMessage("Caching images");
            LoadingOverlay.sharedInstance.showOverlay();
            for dealer in dealers {
                dispatchEntity(dealer.ArtistThumbnailImageId);
                dispatchEntity(dealer.ArtistImageId);
                dispatchEntity(dealer.ArtPreviewImageId);
            }
            dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), {
                LoadingOverlay.sharedInstance.hideOverlay();
            })
        }
    }
    
    
    //TODO
    func cacheMapImages() {
        
    }
    
    //Caching all entities images
    func cacheAllImages() {
        cacheDealersImages();
    }
    
    //Retrieve cache path in the document directory
    func documentsPathWithFileName(fileName : String) -> String {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return documentsDirectoryPath.stringByAppendingPathComponent(fileName)
    }
    
    //Delete image from cache
    func deleteFromCache(imagePath: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch {
        }
    }
    
    //Cache image in the CachesDirectory
    func cacheImage(imageId : String, completion: (result: Bool) -> Void) {
        let URLRequest = NSURLRequest(URL: NSURL(string: self.baseImage + imageId)!)
        self.downloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value {
                let imageData = UIImageJPEGRepresentation(image,  1.0);
                let imagePath = self.documentsPathWithFileName(imageId + ".jpg")
                self.deleteFromCache(imagePath);
                if !imageData!.writeToFile(imagePath, atomically: false) {
                    print("Error with imageData on image caching manager")
                    completion(result: false)
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
                    completion(result: true)
                }
            }
        }
    }
    
    //Retrieve image from directory
    func retrieveFromCache(imageId: String, imagePlaceholder: UIImage? = nil) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            if (dirPath != "") {
                let readPath = dirPath.stringByAppendingPathComponent(imageId + ".jpg")
                if let image = UIImage(contentsOfFile: readPath) {
                    return image;
                }
                else {
                    var success = false
                    cacheImage(imageId) {
                        (result: Bool) in
                        success = result
                    }
                    if success {
                        return retrieveFromCache(imageId, imagePlaceholder: imagePlaceholder)
                    } else {
                        return imagePlaceholder
                    }
                }
            }
        }
        return imagePlaceholder
    }
}