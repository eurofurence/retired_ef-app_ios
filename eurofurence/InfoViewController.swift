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
    var markdown: Markdown!
    
    static let htmlStyle = "<style>"
        + "p, ul, li { font: -apple-system-body; color: #FFF; }"
        + "h1 { font: -apple-system-headline; color: #FFF; }"
        + "h2 { font: -apple-system-subheadline; color: #FFF; }"
        + "h3 { font: -apple-system-body; color: #FFF; }"
        + "h4 { font: -apple-system-body; color: #FFF; }"
        + "</style>"
    static let stripDoubleSlashRegex = try! NSRegularExpression(pattern: "\\\\", options: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var markdownOptions = MarkdownOptions()
        markdownOptions.autoHyperlink = true
        markdownOptions.autoNewlines = true
        markdownOptions.emptyElementSuffix = ">"
        markdownOptions.encodeProblemUrlCharacters = true
        markdownOptions.linkEmails = true
        markdownOptions.strictBoldItalic = true
        markdown = Markdown(options: markdownOptions)
        // Do any additional setup after loading the view.
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
        
        do {
            let infoText = InfoViewController.stripDoubleSlashRegex.stringByReplacingMatchesInString(info.Text, options: [], range: NSRange(location: 0, length: info.Text.characters.count), withTemplate: "\n")
            let htmlText = InfoViewController.htmlStyle + markdown.transform(infoText)
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
