//
//  InfoViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 04/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var linkView: UIView!
    var imageViewDefaultHeight = CGFloat(0.0)
    var info = Info()
    var linkViewLastButton: UIButton? = nil
    var linkViewLastBottomConstraint: NSLayoutConstraint? = nil
    var buttonUrls: [UIButton:NSURL] = [:]
    
    static let htmlStyle = "<style>"
        + "html, p, ul, li { font: -apple-system-body; color: #FFF; }"
        + "h1 { font: -apple-system-headline; color: #FFF; }"
        + "h2 { font: -apple-system-subheadline; color: #FFF; }"
        + "h3 { font: -apple-system-body; color: #FFF; }"
        + "h4 { font: -apple-system-body; color: #FFF; }"
        + "</style>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkView.translatesAutoresizingMaskIntoConstraints = false
        for subview in linkView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func canRotate()->Bool {
        return true
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            self.tabBarController?.tabBar.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        super.viewWillAppear(animated)
        
        if let infoGroup = InfoGroup.getById(info.InfoGroupId) {
            groupLabel.text = infoGroup.Name
        } else {
            groupLabel.text = ""
        }
        titleLabel.text = info.Title
        
        if let imageId = info.ImageIdsAlternative.first {
            imageView.image = ImageManager.sharedInstance.retrieveFromCache(imageId.Id)
            if imageViewDefaultHeight > 0 {
                imageViewHeightConstraint.constant = imageViewDefaultHeight
            }
        } else {
            imageView.image = nil
            if imageViewDefaultHeight == 0 {
                imageViewDefaultHeight = imageViewHeightConstraint.constant
            }
            imageViewHeightConstraint.constant = 0.0
        }
        imageView.sizeToFit()
        
        do {
            let htmlText = WikiText.transformToHtml(info.Text, style: InfoViewController.htmlStyle)
            textView.attributedText = try NSAttributedString(
                data: htmlText.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
        } catch {
            textView.text = info.Text
        }
        
        for subview in linkView.subviews {
            subview.removeFromSuperview()
        }
        linkViewLastButton = nil
        linkViewLastBottomConstraint = nil
        buttonUrls = [:]
        
        linkView.translatesAutoresizingMaskIntoConstraints = false
        for infoUrl in info.Urls {
            addLinkButton(infoUrl)
        }
        
        linkLabel.hidden = buttonUrls.count == 0
    }
    
    func urlButtonAction(button: UIButton) {
        if let url = buttonUrls[button] {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func addLinkButton(infoUrl: InfoUrl) {
        let linkButton = UIButton(type: UIButtonType.RoundedRect)
        linkButton.setTitle(infoUrl.Text, forState: UIControlState.Normal)
        linkButton.accessibilityIdentifier = infoUrl.Text
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.addTarget(self, action: #selector(InfoViewController.urlButtonAction(_:)), forControlEvents: .TouchUpInside)

        linkView.addSubview(linkButton)
        
        if linkViewLastButton != nil {
            if linkViewLastBottomConstraint != nil {
                linkView.removeConstraint(linkViewLastBottomConstraint!)
            }
            // Top Constraint -> lastButton.Bottom
            NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: linkViewLastButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 4).active = true
        } else {
            // Top Constraint -> view.TopMargin
            NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: linkView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: 0).active = true
        }
        // Bottom Constraint -> view.Bottom
        linkViewLastBottomConstraint = NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: linkView, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1.0, constant: 0)
        linkViewLastBottomConstraint!.active = true
        // Leading Constraint -> view.LeadingMargin
        NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: linkView, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 0).active = true
        // Trailing Constraint -> view.TrailingMargin
        NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: linkView, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: 0).active = true
        
        linkViewLastButton = linkButton
        buttonUrls[linkButton] = NSURL(string: infoUrl.Target)
        
        linkView.layoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
