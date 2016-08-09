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
    var isCaching = false
    var toCacheCount = 0
    var doneCachingCount = 0
    
    private func dispatchEntity(entityId: String?) {
        if (entityId != nil) {
            self.toCacheCount += 1
            if LoadingOverlay.sharedInstance.isPresented() {
                LoadingOverlay.sharedInstance.changeMessage("Caching images\n(\(self.doneCachingCount)/\(self.toCacheCount))")
            }
            dispatch_group_enter(self.dispatchGroup)
            dispatch_async(dispatch_get_main_queue()) {
                self.cacheImage(entityId!) {
                    (image: UIImage?) in
                    self.doneCachingCount += 1
                    if LoadingOverlay.sharedInstance.isPresented() {
                        LoadingOverlay.sharedInstance.changeMessage("Caching images\n(\(self.doneCachingCount)/\(self.toCacheCount))")
                    }
                };
            }
            dispatch_group_leave(self.dispatchGroup)
        }
    }
    
    /// Get all dealers in the Realm Database to cache all images with cacheImage
    private func cacheDealersImages() {
        let dealersOptional = Dealer.getAll();
        if let dealers = dealersOptional {
            for dealer in dealers {
                dispatchEntity(dealer.ArtistThumbnailImageId);
                dispatchEntity(dealer.ArtistImageId);
                dispatchEntity(dealer.ArtPreviewImageId);
            }
        }
    }
    
    private func cacheMapImages() {
        if let maps = Map.getAll() {
            for map in maps {
                dispatchEntity(map.ImageId)
            }
        }
    }
    
    /// Caches all images for given `imageIds` or for all currently stored
    /// entities if no IDs are given.
    func cacheAllImages(imageIds: [String]? = nil) {
        if isCaching {
            print("Caching already in progress!")
            return
        }
        isCaching = true
        
        LoadingOverlay.sharedInstance.changeMessage("Caching images");
        LoadingOverlay.sharedInstance.showOverlay();
        if imageIds == nil {
            cacheDealersImages()
            cacheMapImages()
        } else {
            for imageId in imageIds! {
                dispatchEntity(imageId)
            }
        }
        dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), {
            LoadingOverlay.sharedInstance.hideOverlay()
            self.toCacheCount = 0
            self.doneCachingCount = 0
            self.isCaching = false
        })
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
            //print("Failed to delete image at", imagePath)
        }
    }
    
    /// Attempts to retrieve and cache an image with given `imageID`, calling
    /// `completion` with the result of this operation once done.
    func cacheImage(imageId : String, completion: (image: UIImage?) -> Void) {
        let URLRequest = NSURLRequest(URL: NSURL(string: self.baseImage + imageId)!)
        let receipt = self.downloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value, let imageData = UIImageJPEGRepresentation(image,  1.0) {
                let imagePath = self.documentsPathWithFileName(imageId + ".jpg")
                self.deleteFromCache(imagePath)
                if imageData.writeToFile(imagePath, atomically: false) {
                    completion(image: image)
                    return
                } else {
                    print("Error with imageData on image caching manager")
                }
            }
            completion(image: nil)
        }
        
        // in case of a cache hit, completion must be called manually
        if receipt == nil {
            completion(image: retrieveFromCache(imageId))
        }
    }
    
    /// Attempts to retrieve an image from the cache and will try caching it in
    /// case of a cache miss, in which case `imagePlaceholder` is returned until
    /// the final result can be made available via `completion`.
    func retrieveFromCache(imageId: String, imagePlaceholder: UIImage? = nil, completion: ((image: UIImage?) -> Void)? = nil) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            if (dirPath != "") {
                let readPath = dirPath.stringByAppendingPathComponent(imageId + ".jpg")
                if let image = UIImage(contentsOfFile: readPath) {
                    completion != nil ? completion!(image: image) : ()
                    return image;
                }
                else {
                    if completion == nil {
                        cacheImage(imageId, completion: {image in ()})
                    } else {
                        cacheImage(imageId, completion: completion!)
                    }
                }
            } else {
                completion != nil ? completion!(image: imagePlaceholder) : ()
            }
        } else {
            completion != nil ? completion!(image: imagePlaceholder) : ()
        }
        return imagePlaceholder
    }
}