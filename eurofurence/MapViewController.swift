//
//  MapViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 15/02/2016.
//  Updated by Dominik Schöner on 03/08/2016
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MapViewController: UIViewController, UIScrollViewDelegate {
    static let imagePlaceholder = UIImage(named: "ef")
    static let ZOOM_STEPS = 3
    static let MAX_ZOOM_SCALE_FACTOR: CGFloat = 5.0
    static let MIN_ZOOM_SCALE_FACTOR: CGFloat = 1.0
    
    @IBOutlet weak var mapContainerView: UIScrollView!
    @IBOutlet weak var mapSwitchControl: UISegmentedControl!
    var mapViews: [UIImageView] = []
    var doubleTap: UITapGestureRecognizer!
    var currentMap: Int = 0
    let defaultImageView = UIImageView(image: imagePlaceholder)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var firstMapAdded = false
        let maps = Map.getAll()
        for map in maps! {
            if map.isValidAtDateTimeUtc(NSDate.init()) && map.ImageId != nil && map.Description != nil {
                print(map.Description, "(", map.Id, ") is currently valid, added!")
                let mapView = UIImageView(image: MapViewController.imagePlaceholder)
                ImageManager.sharedInstance.retrieveFromCache(map.ImageId!, imagePlaceholder: MapViewController.imagePlaceholder, completion: {
                    image in
                    mapView.image = image
                    mapView.sizeToFit()
                })
                mapView.contentMode = UIViewContentMode.ScaleAspectFit
                mapView.layer.cornerRadius = 11.0
                mapView.clipsToBounds = false
                mapView.backgroundColor = UIColor.whiteColor()
                mapViews.append(mapView)
                if firstMapAdded {
                    mapSwitchControl.insertSegmentWithTitle(map.Description, atIndex: mapSwitchControl.numberOfSegments - 1, animated: false)
                } else {
                    mapSwitchControl.setTitle(map.Description, forSegmentAtIndex: 0)
                    firstMapAdded = true
                }
            } else {
                print(map.Description, "(", map.Id, ") is currently not valid, skipping...")
            }
        }
        
        if(!firstMapAdded) {
            mapSwitchControl.removeSegmentAtIndex(0, animated: false)
        }
        
        // setup map container
        mapContainerView.delegate = self
        mapContainerView.backgroundColor = UIColor(red: 236/255.0, green: 240/255.0, blue: 241/255.0, alpha: 1.0)
        mapContainerView.minimumZoomScale = 1.0
        mapContainerView.maximumZoomScale = 5.0
        
        // add zoom on double tap
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.zoom(_:)))
        doubleTap!.numberOfTapsRequired = 2
        doubleTap!.numberOfTouchesRequired = 1
        mapContainerView!.addGestureRecognizer(doubleTap!)
    }
    
    func canRotate()->Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if currentMap >= 0 && currentMap < mapViews.count {
            switchToMap(currentMap)
        }
    }
    
    @IBAction func ShowLegendBarButtonItem(sender: AnyObject) {
        
    }
    
    /// Switches the currently displayed map to `mapID`. Will do reload map if
    /// given map is already being displayed
    /// - parameters:
    ///   - mapId: id of map to be displayed (see class constants for details)
    func switchToMap(mapId : Int) {
        mapContainerView.subviews.forEach({ $0.removeFromSuperview() })
        
        if mapId < mapViews.count {
            let mapView = mapViews[mapId]
            mapContainerView.contentSize = mapView.bounds.size
            mapContainerView.addSubview(mapView)
            adjustZoomToFit()
        } else if mapViews.count > 0 {
            switchToMap(0)
        } else {
            print("No maps available!")
            return
        }
        
        currentMap = mapId
    }
    
    @IBAction func mapSwitchChanged(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == mapViews.count {
            presentViewController(RoutingAppChooser.sharedInstance.getAlertForAddress("Estrel Hotel Berlin", house: "225", street: "Sonnenallee", zip: "12057", city: "Berlin", country: "Germany", lat: 52.473336, lon: 13.458729), animated: true, completion:nil)
            segmentedControl.selectedSegmentIndex = currentMap
        } else {
            switchToMap(segmentedControl.selectedSegmentIndex)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.mapContainerView.subviews.first
    }
    
    func zoom(tapGesture: UITapGestureRecognizer) {
        if (mapContainerView.zoomScale < mapContainerView.maximumZoomScale) {
            mapContainerView.setZoomScale(mapContainerView.zoomScale + mapContainerView.maximumZoomScale /  CGFloat(MapViewController.ZOOM_STEPS), animated: true)
        } else {
            mapContainerView.setZoomScale(mapContainerView.minimumZoomScale, animated: true)
        }
    }
    
    func adjustZoomToFit() {
        let imageView = mapContainerView.subviews.first as! UIImageView
        let imageSize = imageView.image!.size
        
        let deltaWidth = abs(imageSize.width - mapContainerView.bounds.width)
        let deltaHeight = abs(imageSize.height - mapContainerView.bounds.height)
        
        var zoomFactor: CGFloat!
        // Determine whether height or width are more dominant and zoom to fit the less dominant factor
        if deltaWidth / mapContainerView.bounds.width < deltaHeight / mapContainerView.bounds.height {
            // scale for width
            zoomFactor = mapContainerView.bounds.width/imageSize.width
        } else {
            //scale for height
            zoomFactor = mapContainerView.bounds.height/imageSize.height
        }
        
        zoomFactor = CGFloat(min(1.0, zoomFactor))
        mapContainerView.minimumZoomScale = zoomFactor * MapViewController.MIN_ZOOM_SCALE_FACTOR
        mapContainerView.maximumZoomScale = zoomFactor * MapViewController.MAX_ZOOM_SCALE_FACTOR
        mapContainerView!.setZoomScale(zoomFactor, animated: false)
        
        let scrollRect = CGRect(
            x: imageSize.width * zoomFactor / 2 - mapContainerView.bounds.width / 2,
            y: imageSize.height * zoomFactor / 2 - mapContainerView.bounds.height / 2,
            width: mapContainerView.bounds.width,
            height: mapContainerView.bounds.height)
        print(scrollRect)
        mapContainerView.scrollRectToVisible(scrollRect, animated: false)
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
