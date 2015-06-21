//
//  MapViewDelegate.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/19/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("Pin selected \(view.annotation)")
        
        // get the pin selected
        let pin = view.annotation as! MapPin
        
        self.performSegueWithIdentifier("SeguePhoto", sender: pin)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePhoto" {
            let photoCollectionController = segue.destinationViewController.topViewController as! PhotoCollectionViewController
            photoCollectionController.pin = sender as! MapPin
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        // get the annotation tapped
        let pin = view.annotation as? MapPin
        println("Map Pin \(pin?.latitude), \(pin?.longitude)")

    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        // remember the last map region
        let mapCenterLat = mapView.region.center.latitude
        let mapCenterLong = mapView.region.center.longitude
        let mapSpanLat = mapView.region.span.latitudeDelta
        let mapSpanLong = mapView.region.span.longitudeDelta
        
        NSUserDefaults.standardUserDefaults().setDouble(mapCenterLat, forKey: DefaultMapKeys.centerLat)
        NSUserDefaults.standardUserDefaults().setDouble(mapCenterLong, forKey: DefaultMapKeys.centerLong)
        NSUserDefaults.standardUserDefaults().setDouble(mapSpanLat, forKey: DefaultMapKeys.spanLat)
        NSUserDefaults.standardUserDefaults().setDouble(mapSpanLong, forKey: DefaultMapKeys.spanLong)
    }
}
