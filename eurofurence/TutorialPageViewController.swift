//
//  TutorialViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 09/03/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class TutorialPageViewController: UIPageViewController {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTutorialViewController("News"),
            self.newTutorialViewController("Infos"),
            self.newTutorialViewController("Events"),
            self.newTutorialViewController("Map")
        ]
    }()
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func newTutorialViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Tutorial", bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)TutorialViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        view.backgroundColor = UIColor.white
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.white
        UIPageControl.appearance().backgroundColor = UIColor(red: 4/255.0, green: 96/255.0, blue: 88/255.0, alpha: 0.9)
        
        let dateStart = Date()
        UserDefaults.standard.set(dateStart, forKey: "tutorialStarted")
        FIRAnalytics.logEvent(withName: kFIREventTutorialBegin, parameters: [
            kFIRParameterValue: dateStart.description as NSObject,
            kFIRParameterContentType: "date" as NSObject])
        Answers.logCustomEvent(withName: kFIREventTutorialBegin, customAttributes: [
            kFIRParameterValue: dateStart.description as NSObject,
            kFIRParameterContentType: "date" as NSObject])
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
