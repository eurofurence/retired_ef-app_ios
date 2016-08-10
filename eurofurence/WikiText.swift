//
//  WikiText.swift
//  eurofurence
//
//  Created by Dominik Schöner on 09/08/16.
//  Based on code ported to Swift from C# code by Luchs
//  Source: https://github.com/eurofurence/ef-app_wp/blob/master/Eurofurence.Companion/ViewModel/Converter/WikiTextToHtmlConverter.cs
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation

class WikiText {
    private static let _regexPreceedFirstListItemWithLineBreaks = try! NSRegularExpression(pattern: "(\\n)(?<!  \\* )([^\\n]+)(\\n)((  \\* [^\\n]+\\n)+(?!  \\* ))", options: [])
    private static let _regexSucceedLastListItemWithLineBreaks = try! NSRegularExpression(pattern: "(\\n  \\*[^\\n]+\\n)(?!  \\* )", options: [])
    private static let _regexParseListItems = try! NSRegularExpression(pattern: "\n  \\* ([^\\n]*)", options: [])
    private static let _regexBoldItems = try! NSRegularExpression(pattern: "\\*\\*([^\\*]*)\\*\\*", options: [])
    private static let _regexItalics = try! NSRegularExpression(pattern: "\\*([^\\*\\n]*)\\*", options: [])
    
    static func transformToHtml(wikiText:String, style:String = "")->String {
        if !wikiText.isEmpty {
            // Normalize line breaks
            let htmlText = NSMutableString(string: "<html>\n" + style + wikiText + "\n</html>")
            htmlText.replaceOccurrencesOfString("\\\\", withString: "<br>\n", options: [], range: NSRange(location: 0, length: htmlText.length))
            htmlText.replaceOccurrencesOfString("\n\n", withString: "<br>\n<br>\n", options: [], range: NSRange(location: 0, length: htmlText.length))
            
            WikiText._regexPreceedFirstListItemWithLineBreaks.replaceMatchesInString(htmlText, options: [], range: NSRange(location: 0, length: htmlText.length), withTemplate: "$1<br>\n<ul>\n$2$3$4")
            WikiText._regexSucceedLastListItemWithLineBreaks.replaceMatchesInString(htmlText, options: [], range: NSRange(location: 0, length: htmlText.length), withTemplate: "$1</ul>\n<br>\n")
            WikiText._regexParseListItems.replaceMatchesInString(htmlText, options: [], range: NSRange(location: 0, length: htmlText.length), withTemplate: "\n<li>$1</li>")
            WikiText._regexBoldItems.replaceMatchesInString(htmlText, options: [], range: NSRange(location: 0, length: htmlText.length), withTemplate: "<b>$1</b>")
            WikiText._regexItalics.replaceMatchesInString(htmlText, options: [], range: NSRange(location: 0, length: htmlText.length), withTemplate: "<i>$1</i>")
            
            return String(htmlText)
        }
        
        return ""
    }
    
}