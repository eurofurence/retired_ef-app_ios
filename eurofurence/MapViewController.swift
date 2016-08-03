//
//  MapViewController.swift
//  eurofurence
//
//  Created by Vincent BONMARCHAND on 15/02/2016.
//  Copyright © 2016 eurofurence. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UIScrollViewDelegate {
    static let HOTEL_MAP:   Int = 0
    static let DDEN_MAP:    Int = 1
    static let AREA_MAP:    Int = 2
    static let DEFAULT_MAP: Int = HOTEL_MAP
    
    @IBOutlet weak var mapContainerView: UIScrollView!
    @IBOutlet weak var mapSwitchControl: UISegmentedControl!
    var hotelMapView: UIImageView!
    var ddenMapView: UIImageView!
    var doubleTap: UITapGestureRecognizer!
    var currentMap: Int = -1
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize map for Hotel
        hotelMapView = UIImageView(image: UIImage(named: "ef21map"))
        hotelMapView.contentMode = UIViewContentMode.ScaleAspectFit
        hotelMapView!.layer.cornerRadius = 11.0
        hotelMapView!.clipsToBounds = false
        
        // initialize map for Dealer's Den
        ddenMapView = UIImageView(image: UIImage(named: "ef"))
        ddenMapView.contentMode = UIViewContentMode.ScaleAspectFit
        ddenMapView!.layer.cornerRadius = 11.0
        ddenMapView!.clipsToBounds = false
        
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
        
        mapSwitchControl.addTarget(self, action: #selector(MapViewController.mapSwitchChanged(_:)), forControlEvents: UIControlEvents.AllEvents)
        
        switchToMap(MapViewController.DEFAULT_MAP)
    }
    @IBAction func ShowLegendBarButtonItem(sender: AnyObject) {
        
    }
    
    /// Switches the currently displayed map to `mapID`. Will do nothing if 
    /// given map is already being displayed
    /// - parameters:
    ///   - mapId: id of map to be displayed (see class constants for details)
    func switchToMap(mapID : Int) {
        if mapID == currentMap {
            // mapID is already current map. Nothing to do here!
            return
        }
        
        mapContainerView.subviews.forEach({ $0.removeFromSuperview() })
        
        switch mapID {
        case 0:
            mapContainerView.contentSize = hotelMapView.bounds.size
            mapContainerView.addSubview(hotelMapView)
            break
        case 1:
            mapContainerView.contentSize = ddenMapView.bounds.size
            mapContainerView.addSubview(ddenMapView)
            break
        default:
            // Unrecognized mapID, switch to default
            switchToMap(MapViewController.DEFAULT_MAP)
            return
        }
        
        currentMap = mapID
    }
    
    func mapSwitchChanged(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case MapViewController.HOTEL_MAP:
            switchToMap(MapViewController.HOTEL_MAP)
            break
        case MapViewController.DDEN_MAP:
            switchToMap(MapViewController.DDEN_MAP)
            break
        case MapViewController.AREA_MAP:
            presentViewController(RoutingAppChooser.sharedInstance.getAlertForAddress("Estrel Hotel Berlin", house: "225", street: "Sonnenallee", zip: "12057", city: "Berlin", country: "Germany"), animated: true, completion:nil)
            segmentedControl.selectedSegmentIndex = currentMap
            break
        default:
            ()
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.mapContainerView.subviews.first
    }
    
    func zoom(tapGesture: UITapGestureRecognizer) {
        if (mapContainerView!.zoomScale == mapContainerView!.minimumZoomScale) {
            let center = tapGesture.locationInView(mapContainerView!)
            let size = (self.mapContainerView.subviews.first as! UIImageView).image!.size
            let zoomRect = CGRectMake(center.x, center.y, (size.width / 4), (size.height / 4))
            mapContainerView!.zoomToRect(zoomRect, animated: true)
        } else {
            mapContainerView!.setZoomScale(mapContainerView!.minimumZoomScale, animated: true)
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
