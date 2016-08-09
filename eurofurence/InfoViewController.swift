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
    @IBOutlet weak var textView: UITextView!
    var info = Info()
    
    static let htmlStyle = "<style>"
        + "html, p, ul, li { font: -apple-system-body; color: #FFF; }"
        + "h1 { font: -apple-system-headline; color: #FFF; }"
        + "h2 { font: -apple-system-subheadline; color: #FFF; }"
        + "h3 { font: -apple-system-body; color: #FFF; }"
        + "h4 { font: -apple-system-body; color: #FFF; }"
        + "</style>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func canRotate()->Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let infoGroup = InfoGroup.getById(info.InfoGroupId) {
            groupLabel.text = infoGroup.Name
        } else {
            groupLabel.text = ""
        }
        titleLabel.text = info.Title
        
        do {
            let htmlText = WikiText.transformToHtml(info.Text, style: InfoViewController.htmlStyle)
            textView.attributedText = try NSAttributedString(
                data: htmlText.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
        } catch {
            textView.text = info.Text
        }
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
