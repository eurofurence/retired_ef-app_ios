//
//  Loader.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import UIKit

public class LoadingOverlay {
    
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
    var activityIndicator : UIActivityIndicatorView!
    private var presented = false
    
    static let sharedInstance = LoadingOverlay()
    
    init() {
        activityIndicator = UIActivityIndicatorView()
        alert.view.tintColor = UIColor.blackColor()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        alert.view.addSubview(self.activityIndicator)
    }
    
    public func isPresented()->Bool {
        return presented
    }
    
    public func showOverlay() {
        dispatch_async(dispatch_get_main_queue()) {
            if !self.presented {
                self.presented = true
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(self.alert, animated: true, completion: nil)
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    public func hideOverlay() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.presented {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
                self.presented = false
            }
        }
    }
    
    public func changeMessage(message: String) {
        alert.message = message;
    }
}