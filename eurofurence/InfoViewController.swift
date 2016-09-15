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
    var buttonUrls: [UIButton:URL] = [:]
    
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
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
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
                data: htmlText.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
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
        
        linkLabel.isHidden = buttonUrls.count == 0
    }
    
    func urlButtonAction(_ button: UIButton) {
        if let url = buttonUrls[button] {
            UIApplication.shared.openURL(url)
        }
    }
    
    func addLinkButton(_ infoUrl: InfoUrl) {
        let linkButton = UIButton(type: UIButtonType.roundedRect)
        linkButton.setTitle(infoUrl.Text, for: UIControlState())
        linkButton.accessibilityIdentifier = infoUrl.Text
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.addTarget(self, action: #selector(InfoViewController.urlButtonAction(_:)), for: .touchUpInside)

        linkView.addSubview(linkButton)
        
        if linkViewLastButton != nil {
            if linkViewLastBottomConstraint != nil {
                linkView.removeConstraint(linkViewLastBottomConstraint!)
            }
            // Top Constraint -> lastButton.Bottom
            NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: linkViewLastButton, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 4).isActive = true
        } else {
            // Top Constraint -> view.TopMargin
            NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: linkView, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 0).isActive = true
        }
        // Bottom Constraint -> view.Bottom
        linkViewLastBottomConstraint = NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: linkView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1.0, constant: 0)
        linkViewLastBottomConstraint!.isActive = true
        // Leading Constraint -> view.LeadingMargin
        NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: linkView, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1.0, constant: 0).isActive = true
        // Trailing Constraint -> view.TrailingMargin
        NSLayoutConstraint(item: linkButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: linkView, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1.0, constant: 0).isActive = true
        
        linkViewLastButton = linkButton
        buttonUrls[linkButton] = URL(string: infoUrl.Target)
        
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
