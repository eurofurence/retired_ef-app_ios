//
//  Loader.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import UIKit

public class LoadingOverlay{
    
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!
    var presented : Bool = false
    
    static let sharedInstance = LoadingOverlay()
    
    init(){
        self.overlayView = UIView()
        self.activityIndicator = UIActivityIndicatorView()
        self.alert.view.tintColor = UIColor.blackColor()
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        self.alert.view.addSubview(self.activityIndicator)
    }
    
    public func showOverlay() {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(self.alert, animated: true, completion: nil)
        self.activityIndicator.startAnimating()
        self.presented = true
    }
    
    public func hideOverlay() {
        if (presented) {
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(false, completion:  nil)
        }
    }
}