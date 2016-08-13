//
//  LeftViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/08/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import Foundation
import UIKit

enum LeftMenu: Int {
    case Settings = 0
    case About
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var menus = ["Settings", "About"]
    var settingsTableViewController: UIViewController!
    var aboutViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "SlideMenu", bundle: nil)
        let settingsTableViewController = storyboard.instantiateViewControllerWithIdentifier("SettingsTableView") as! SettingsTableViewController
        self.settingsTableViewController = UINavigationController(rootViewController: settingsTableViewController)
        //self.settingsTableViewController = UINavigationController(rootViewController: settingsTableViewController)
        
        let aboutViewController = storyboard.instantiateViewControllerWithIdentifier("AboutView") as! AboutViewController
        self.aboutViewController = UINavigationController(rootViewController: aboutViewController)
        self.tableView.registerCellClass(MenuTableViewCell.self)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.versionLabel.text = "Version: " + ConfigManager.sharedInstance.appVersion;
        super.viewDidAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Settings:
            self.slideMenuController()?.changeMainViewController(self.settingsTableViewController, close: true)
        case .About:
            self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .Settings, .About:
                return MenuTableViewCell.height()
            }
        }
        return 0
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
        case .Settings, .About:
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
}

extension LeftViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}
