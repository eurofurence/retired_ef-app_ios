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
import Firebase
import Crashlytics

class ImageManager {
    static let _imageFileExtension = "jpg"
    static let _imageFilePattern = try! NSRegularExpression(pattern: "^([a-f0-9\\-]*)\\." + _imageFileExtension + "$", options: [])
    let baseImage = ConfigManager.sharedInstance.apiBaseUrl +  "ImageData/";
    let downloader = ConfigManager.sharedInstance.diskImageDownloader();
    static let sharedInstance = ImageManager();
    let dispatchGroup = DispatchGroup();
    var isCaching = false
    /// temporary list of imageIds from full caching run for pruning
    var newImageIds: [String]? = nil
    var toCacheCount = 0
    var doneCachingCount = 0
    
    private func dispatchEntity(_ entityId: String?, hasChanged: Bool = false) {
        if (entityId != nil) {
            // add imageId to new list if performing full chaching run
            if newImageIds != nil {
                newImageIds?.append(entityId!)
            }
            
            if(!isCached(entityId!) || hasChanged) {
                self.toCacheCount += 1
                if LoadingOverlay.sharedInstance.isPresented() {
                    LoadingOverlay.sharedInstance.changeMessage("Caching images\n(\(self.doneCachingCount)/\(self.toCacheCount))")
                }
                self.dispatchGroup.enter()
                DispatchQueue.main.async {
                    if self.isCached(entityId!) && hasChanged {
                        self.deleteFromCache(self.getPathForId(entityId!))
                    }
                    self.cacheImage(entityId!) {
                        (image: UIImage?) in
                        self.doneCachingCount += 1
                        if LoadingOverlay.sharedInstance.isPresented() {
                            LoadingOverlay.sharedInstance.changeMessage("Caching images\n(\(self.doneCachingCount)/\(self.toCacheCount))")
                        }
                        self.dispatchGroup.leave()
                    };
                }
            }
        }
    }
    
    /// Checks currently cached images against list of images from last full
    /// caching run and prunes all old images from cache.
    private func pruneCache() {
        if newImageIds != nil {
            let timeStarted = Date()
            var deletedImages = 0
            for imageId in getCachedImageIds() {
                if newImageIds?.index(of: imageId) == nil {
                    //print("pruning image", imageId)
                    deleteFromCache(getPathForId(imageId))
                    deletedImages += 1
                }
            }
            FIRAnalytics.logEvent(withName: "images_cache_pruned", parameters: [
                kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
                kFIRParameterContentType: "duration" as NSObject,
                "deleted_images": deletedImages as NSObject])
            Answers.logCustomEvent(withName: "images_cache_pruned", customAttributes: [
                kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
                kFIRParameterContentType: "duration" as NSObject,
                "deleted_images": deletedImages as NSObject])
            newImageIds = nil
        }
    }
    
    /// Clear all images in cache
    func clearCache(_ completion: (_ result: Bool) -> Void) {
        var deletedImages = 0
        let timeStarted = Date()
        for imageId in getCachedImageIds() {
            deleteFromCache(getPathForId(imageId))
            deletedImages += 1
        }
        FIRAnalytics.logEvent(withName: "images_cache_cleared", parameters: [
            kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
            kFIRParameterContentType: "duration" as NSObject,
            "deleted_images": deletedImages as NSObject])
        Answers.logCustomEvent(withName: "images_cache_cleared", customAttributes: [
            kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
            kFIRParameterContentType: "duration" as NSObject,
            "deleted_images": deletedImages as NSObject])
        completion(true);
    }
    
    /// Caches all images for given `imageIds` or for all currently stored Map
    /// and Dealer entities if no IDs are given (full caching run).
    func cacheAllImages(_ imageIds: [String]? = nil, completion: ((Void) -> Void)? = nil) {
        if isCaching {
            //print("Caching already in progress!")
            return
        }
        let timeStarted = Date()
        isCaching = true
        FIRAnalytics.logEvent(withName: "images_caching_initiated", parameters: [
            kFIRParameterValue: timeStarted.description as NSObject,
            kFIRParameterContentType: "date" as NSObject])
        Answers.logCustomEvent(withName: "images_caching_initiated", customAttributes: [
            kFIRParameterValue: timeStarted.description as NSObject,
            kFIRParameterContentType: "date" as NSObject])
        
        //print("Caching images...")
        if LoadingOverlay.sharedInstance.isPresented() {
            LoadingOverlay.sharedInstance.changeMessage("Caching images")
        }
        if imageIds == nil {
            newImageIds = []
            
            let defaults = UserDefaults.standard
            let lastDatabaseUpdate = defaults.object(forKey: ApiManager.LAST_DATABASE_UPDATE_DEFAULT)
            
            if let images = Image.getAll() {
                for image in images {
                    var hasChanged = true
                    
                    if let imageUpdate = Date.dateFromISOString(image.LastChangeDateTimeUtc), let lastDatabaseUpdate = lastDatabaseUpdate as? Date , imageUpdate.compare(lastDatabaseUpdate) == ComparisonResult.orderedAscending {
                        
                        hasChanged = false
                    }
                    
                    dispatchEntity(image.Id, hasChanged: hasChanged)
                }
            }
        } else {
            for imageId in imageIds! {
                dispatchEntity(imageId)
            }
        }
        self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            // will only be executed if full caching run was performed
            self.pruneCache()
            print("Finished caching images.")
            FIRAnalytics.logEvent(withName: "images_caching_completed", parameters: [
                kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
                kFIRParameterContentType: "duration" as NSObject,
                "cached_images": self.doneCachingCount as NSObject])
            Answers.logCustomEvent(withName: "images_caching_completed", customAttributes: [
                kFIRParameterValue: Date().timeIntervalSince(timeStarted) as NSObject,
                kFIRParameterContentType: "duration" as NSObject,
                "cached_images": self.doneCachingCount as NSObject])
            (completion != nil) ? completion!() : ()
            self.toCacheCount = 0
            self.doneCachingCount = 0
            self.isCaching = false
        })
    }
    
    func getCachedImageIds()->[String] {
        let fileManager = FileManager.default
        var imageIds: [String] = []
        do {
            for imageFile in try fileManager.contentsOfDirectory(atPath: self.getImageCachePath()) {
                let imageFileId = NSMutableString(string: imageFile)
                if ImageManager._imageFilePattern.replaceMatches(in: imageFileId, options: [], range: NSRange(location: 0, length: imageFile.utf16.count), withTemplate: "$1") == 1 {
                    
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
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    func getPathForId(_ imageId: String)->String {
        return getImageCachePath().stringByAppendingPathComponent(imageId + "." + ImageManager._imageFileExtension)
    }
    
    //Delete image from cache
    func deleteFromCache(_ imagePath: String) {
        do {
            try FileManager.default.removeItem(atPath: imagePath)
        } catch {
            print("Failed to delete image at", imagePath)
        }
    }
    
    //Avoid file to be saved by iCloud
    func addSkipBackupAttributeToItemAtURL(_ url:URL) -> Bool {
        
        assert(FileManager.default.fileExists(atPath: url.path), "File \(url) does not exist")
        
        var success: Bool
        do {
            try (url as NSURL).setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey)
            success = true
        } catch let error as NSError {
            success = false
            print("Error excluding \(url.lastPathComponent) from backup \(error)");
        }
        
        return success
    }
    
    /// Attempts to retrieve and cache an image with given `imageID`, calling
    /// `completion` with the result of this operation once done.
    func cacheImage(_ imageId : String, completion: @escaping (_ image: UIImage?) -> Void) {
        // in case of a cache hit, completion must be called manually
        if isCached(imageId) {
            retrieveFromCache(imageId, completion: completion)
            return
        }
        
        if let image = Image.getById(imageId), let imageUrl = URL(string: image.Url.replacingOccurrences(of: "{Endpoint}", with: ConfigManager.sharedInstance.apiBaseUrl)) {
            
            let urlRequest = Foundation.URLRequest(url: imageUrl)
            let receipt = self.downloader.download(urlRequest, completion: { response in
                if let image = response.result.value, let imageData = UIImageJPEGRepresentation(image,  1.0) {
                    let imagePath = Foundation.URL(fileURLWithPath: self.getPathForId(imageId))
                    //print("Downloaded image", imageId)
                    do {
                        try imageData.write(to: imagePath)
                        self.addSkipBackupAttributeToItemAtURL(imagePath);
                        completion(image)
                        return
                    } catch {
                        print("Error with imageData on image caching manager")
                    }
                }
                completion(nil)
            })
            
            // in case of a downloader cache hit, completion must be called manually
            if receipt == nil {
                //print("Image already in downloader cache", imageId)
            }
        } else {
            completion(nil)
        }
    }
    
    /// Attempts to retrieve an image from the cache and will try caching it in
    /// case of a cache miss, in which case `imagePlaceholder` is returned until
    /// the final result can be made available via `completion`.
    func retrieveFromCache(_ imageId: String, imagePlaceholder: UIImage? = nil, completion: ((_ image: UIImage?) -> Void)? = nil) -> UIImage? {
        if isCached(imageId) {
            if let image = UIImage(contentsOfFile: getPathForId(imageId)) {
                completion != nil ? completion!(image) : ()
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
        completion != nil ? completion!(imagePlaceholder) : ()
        return imagePlaceholder
    }
    
    func isCached(_ imageId: String)->Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: getPathForId(imageId))
    }
}
