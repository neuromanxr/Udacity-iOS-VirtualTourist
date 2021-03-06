//
//  MapViewGesture.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/19/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import MapKit

extension MapViewController {
    
    func addGestureRecognizer() {
        self.gesture.addTarget(self, action: "gestureAction:")

        self.mapView.addGestureRecognizer(self.gesture)
    }
    
    func gestureAction(sender: UIGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            println("Gesture began")
            self.activityIndicator.startAnimating()
        case .Ended:
            self.getCoordinateFromPoint(sender)
        default:
            return
        }
    }
    
    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D, withCompletion completion: (location: String?, error: NSError?) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { (result: [AnyObject]!, error: NSError!) -> Void in
            if let error = error {
                println("error geocoding in function \(error)")
                completion(location: nil, error: error)
                
            } else {
                let placemark = result.first as! CLPlacemark
                var location = String()
                
                let addressDictionary = placemark.addressDictionary
                if let locationCountry = addressDictionary["Country"] as? String {
                    location = "\(locationCountry)"
                    if let locationCity = addressDictionary["City"] as? String {
                        
                        location = "\(locationCity), \(locationCountry)"
                        println("Location: \(location)")
                    }
                }
                
                println("address dictionary \(addressDictionary)")
                // call completion
                completion(location: location, error: nil)
            }
        })
    }
    
    func getCoordinateFromPoint(sender: UIGestureRecognizer) {
        
        // get the coordinate from the user touch
        let point = sender.locationInView(self.mapView)
        let coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
        
        // get the location string
        self.getLocationFromCoordinate(coordinate, withCompletion: { (location, error) -> () in
            if let error = error {
                println("Error getting location \(error)")
                if self.activityIndicator.isAnimating() {
                    self.activityIndicator.stopAnimating()
                }
            } else {
                println("Location: \(location)")
                
                // set the pin title
                let title = location!
                // create the annotation from coordinate
                self.addAnnotationToCoordinate(coordinate, location: title)
                if self.activityIndicator.isAnimating() {
                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        println("Annotation added")
    }
    
    func addAnnotationToCoordinate(coordinate: CLLocationCoordinate2D, location: String) {
        
        // create a MapPin
        let dictionary: [String: AnyObject] = [
            MapPin.Keys.Title: location,
            MapPin.Keys.Latitude: coordinate.latitude,
            MapPin.Keys.Longitude: coordinate.longitude
        ]
        // create the pin and then insert it into the context
        let pin = MapPin(dictionary: dictionary, context: self.sharedContext)
        
        // save the context
        CoreDataStackManager.sharedInstance().saveContext()
        println("Context Saved")
        
        // show the new pin on the map
        self.mapView.addAnnotation(pin)
        
        // center map on pin
        centerMapOnPin(pin)
    }
    
    func centerMapOnPin(pin: MapPin) {
        
        let center = CLLocationCoordinate2DMake(pin.coordinate.latitude, pin.coordinate.longitude)
        let span = MKCoordinateSpanMake(5.0, 5.0)
        let region = MKCoordinateRegionMake(center, span)
        
        self.mapView.setRegion(region, animated: true)
    }
}
