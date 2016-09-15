//
//  Loader.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 19/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import UIKit

open class LoadingOverlay {
    
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    var activityIndicator : UIActivityIndicatorView!
    private var presented = false
    
    static let sharedInstance = LoadingOverlay()
    
    init() {
        activityIndicator = UIActivityIndicatorView()
        alert.view.tintColor = UIColor.black
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        alert.view.addSubview(self.activityIndicator)
    }
    
    open func isPresented()->Bool {
        return presented
    }
    
    open func showOverlay() {
        DispatchQueue.main.async {
            if !self.presented {
                self.presented = true
                UIApplication.shared.keyWindow?.rootViewController?.present(self.alert, animated: true, completion: nil)
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    open func hideOverlay() {
        DispatchQueue.main.async {
            if self.presented {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
                self.presented = false
            }
        }
    }
    
    open func changeMessage(_ message: String) {
        alert.message = message;
    }
}
