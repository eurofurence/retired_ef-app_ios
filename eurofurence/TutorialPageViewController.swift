//
//  TutorialViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTutorialViewController("News"),
            self.newTutorialViewController("Infos"),
            self.newTutorialViewController("Events"),
            self.newTutorialViewController("Map")
        ]
    }()
    
    private func newTutorialViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Tutorial", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(name)TutorialViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
        view.backgroundColor = UIColor.whiteColor()
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
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

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}