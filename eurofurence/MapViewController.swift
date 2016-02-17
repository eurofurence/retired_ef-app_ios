//
//  MapViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 15/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var doubleTap: UITapGestureRecognizer!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "ef21map"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(red: 236/255.0, green: 240/255.0, blue: 241/255.0, alpha: 1.0)
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        scrollView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        self.doubleTap = UITapGestureRecognizer(target: self, action: "zoom:")
        self.doubleTap!.numberOfTapsRequired = 2
        self.doubleTap!.numberOfTouchesRequired = 1
        self.scrollView!.addGestureRecognizer(self.doubleTap!)
        view.addSubview(scrollView)
        imageView!.layer.cornerRadius = 11.0
        imageView!.clipsToBounds = false
        scrollView.addSubview(imageView)


        // Do any additional setup after loading the view.
    }
    @IBAction func ShowLegendBarButtonItem(sender: AnyObject) {
        
    }
    
    func zoom(tapGesture: UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale == self.scrollView!.minimumZoomScale) {
            let center = tapGesture.locationInView(self.scrollView!)
            let size = self.imageView!.image!.size
            let zoomRect = CGRectMake(center.x, center.y, (size.width / 4), (size.height / 4))
            self.scrollView!.zoomToRect(zoomRect, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
