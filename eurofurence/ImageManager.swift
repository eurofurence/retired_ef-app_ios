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
    static let _imageFileExtension = "jpg"
    static let _imageFilePattern = try! NSRegularExpression(pattern: "^([a-f0-9\\-]*)\\." + _imageFileExtension + "$", options: [])
    let baseImage = ConfigManager.sharedInstance.apiBaseUrl +  "ImageData/";
    let downloader = ConfigManager.sharedInstance.diskImageDownloader();
    static let sharedInstance = ImageManager();
    let dispatchGroup = dispatch_group_create();
    var isCaching = false
    /// temporary list of imageIds from full caching run for pruning
    var newImageIds: [String]? = nil
    var toCacheCount = 0
    var doneCachingCount = 0
    
    private func dispatchEntity(entityId: String?) {
        if (entityId != nil) {
            // add imageId to new list if performing full chaching run
            if newImageIds != nil {
                newImageIds?.append(entityId!)
            }
            
            if(!isCached(entityId!)) {
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
                        dispatch_group_leave(self.dispatchGroup)
                    };
                }
            }
        }
    }
    
    private func cacheInfoImages() {
        if let infos = Info.getAll() {
            for info in infos {
                for imageId in info.ImageIdsAlternative {
                    dispatchEntity(imageId.Id)
                }
            }
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
    
    /// Checks currently cached images against list of images from last full
    /// caching run and prunes all old images from cache.
    private func pruneCache() {
        if newImageIds != nil {
            for imageId in getCachedImageIds() {
                if newImageIds?.indexOf(imageId) == nil {
                    print("pruning image", imageId)
                    deleteFromCache(getPathForId(imageId))
                }
            }
            newImageIds = nil
        }
    }
    
    /// Clear all images in cache
    func clearCache(completion: (result: Bool) -> Void) {
        for imageId in getCachedImageIds() {
            deleteFromCache(getPathForId(imageId))
        }
        completion(result : true);
    }
    
    /// Caches all images for given `imageIds` or for all currently stored Map
    /// and Dealer entities if no IDs are given (full caching run).
    func cacheAllImages(imageIds: [String]? = nil, completion: ((Void) -> Void)? = nil) {
        if isCaching {
            print("Caching already in progress!")
            return
        }
        isCaching = true
        
        print("Caching images...")
        if LoadingOverlay.sharedInstance.isPresented() {
            LoadingOverlay.sharedInstance.changeMessage("Caching images")
        }
        if imageIds == nil {
            newImageIds = []
            cacheInfoImages()
            cacheDealersImages()
            cacheMapImages()
        } else {
            for imageId in imageIds! {
                dispatchEntity(imageId)
            }
        }
        dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), {
            // will only be executed if full caching run was performed
            self.pruneCache()
            print("Finished caching images.")
            (completion != nil) ? completion!() : ()
            self.toCacheCount = 0
            self.doneCachingCount = 0
            self.isCaching = false
        })
    }
    
    func getCachedImageIds()->[String] {
        let fileManager = NSFileManager.defaultManager()
        var imageIds: [String] = []
        do {
            for imageFile in try fileManager.contentsOfDirectoryAtPath(self.getImageCachePath()) {
                let imageFileId = NSMutableString(string: imageFile)
                if ImageManager._imageFilePattern.replaceMatchesInString(imageFileId, options: [], range: NSRange(location: 0, length: imageFile.utf16.count), withTemplate: "$1") == 1 {
                    
                    imageIds.append(imageFileId as String)
                }
            }
        } catch {
            print("Failed to list cache directory.")
        }
        return imageIds
    }
    
    //Retrieve cache path in the document directory
    func getImageCachePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
    }
    
    func getPathForId(imageId: String)->String {
        return getImageCachePath().stringByAppendingPathComponent(imageId + "." + ImageManager._imageFileExtension)
    }
    
    //Delete image from cache
    func deleteFromCache(imagePath: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch {
            //print("Failed to delete image at", imagePath)
        }
    }
    
    //Avoid file to be saved by iCloud
    func addSkipBackupAttributeToItemAtURL(filePath:String) -> Bool
    {
        let URL:NSURL = NSURL.fileURLWithPath(filePath)
        
        assert(NSFileManager.defaultManager().fileExistsAtPath(filePath), "File \(filePath) does not exist")
        
        var success: Bool
        do {
            try URL.setResourceValue(true, forKey:NSURLIsExcludedFromBackupKey)
            success = true
        } catch let error as NSError {
            success = false
            print("Error excluding \(URL.lastPathComponent) from backup \(error)");
        }
        
        return success
    }
    
    /// Attempts to retrieve and cache an image with given `imageID`, calling
    /// `completion` with the result of this operation once done.
    func cacheImage(imageId : String, completion: (image: UIImage?) -> Void) {
        // in case of a cache hit, completion must be called manually
        if isCached(imageId) {
            retrieveFromCache(imageId, completion: completion)
            return
        }
        
        let URLRequest = NSURLRequest(URL: NSURL(string: self.baseImage + imageId)!)
        let receipt = self.downloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value, let imageData = UIImageJPEGRepresentation(image,  1.0) {
                let imagePath = self.getPathForId(imageId)
                //print("Downloaded image", imageId)
                if imageData.writeToFile(imagePath, atomically: false) {
                    self.addSkipBackupAttributeToItemAtURL(imagePath);
                    completion(image: image)
                    return
                } else {
                    print("Error with imageData on image caching manager")
                }
            }
            completion(image: nil)
        }
        
        // in case of a downloader cache hit, completion must be called manually
        if receipt == nil {
            //print("Image already in downloader cache", imageId)
        }
    }
    
    /// Attempts to retrieve an image from the cache and will try caching it in
    /// case of a cache miss, in which case `imagePlaceholder` is returned until
    /// the final result can be made available via `completion`.
    func retrieveFromCache(imageId: String, imagePlaceholder: UIImage? = nil, completion: ((image: UIImage?) -> Void)? = nil) -> UIImage? {
        if isCached(imageId) {
            if let image = UIImage(contentsOfFile: getPathForId(imageId)) {
                completion != nil ? completion!(image: image) : ()
                return image;
            }
        }
        else {
            if completion == nil {
                cacheImage(imageId, completion: {image in ()})
            } else {
                cacheImage(imageId, completion: completion!)
            }
        }
        completion != nil ? completion!(image: imagePlaceholder) : ()
        return imagePlaceholder
    }
    
    func isCached(imageId: String)->Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(getPathForId(imageId))
    }
}