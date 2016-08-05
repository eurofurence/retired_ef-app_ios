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
    let dispatchGroup = dispatch_group_create()
    
    /// Get all dealers in the Realm Database to cache all images with cacheImage
    func cacheDealersImages() {
        let dealersOptional = Dealer.getAll();
        if let dealers = dealersOptional {
            LoadingOverlay.sharedInstance.changeMessage("Caching dealers images ...");
            LoadingOverlay.sharedInstance.showOverlay();
            for dealer in dealers {
                if (dealer.ArtistThumbnailImageId != nil) {
                    dispatch_group_enter(self.dispatchGroup)
                    cacheImage(dealer.ArtistThumbnailImageId!) {
                        (result: Bool) in
                        dispatch_group_leave(self.dispatchGroup)
                    };
                }
                if (dealer.ArtistImageId != nil) {
                    dispatch_group_enter(self.dispatchGroup)
                    cacheImage(dealer.ArtistImageId!){
                        (result: Bool) in
                        dispatch_group_leave(self.dispatchGroup)
                    };
                }
                if (dealer.ArtPreviewImageId != nil) {
                    dispatch_group_enter(self.dispatchGroup)
                    cacheImage(dealer.ArtPreviewImageId!){
                        (result: Bool) in
                        dispatch_group_leave(self.dispatchGroup)
                    };
                }
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
                if !imageData!.writeToFile(imagePath, atomically: false)
                {
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
                    cacheImage(imageId){
                        (result: Bool) in
                    };
                    return retrieveFromCache(imageId, imagePlaceholder: imagePlaceholder)
                }
            }
        }
        return imagePlaceholder != nil ? imagePlaceholder : nil;
    }
};