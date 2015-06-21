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
        case .Ended:
            self.getCoordinateFromPoint(sender)
        default:
            return
        }
    }
    
    // TODO: make function for Began state
    
    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D, withCompletion completion: (location: String?, error: NSError?) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { (result: [AnyObject]!, error: NSError!) -> Void in
            if let error = error {
                println("error geocoding in function \(error)")
                completion(location: nil, error: error)
                
            } else {
                let placemark = result.first as! CLPlacemark
                let addressDictionary = placemark.addressDictionary
//                let locationCity = addressDictionary["City"] as! String
                let locationCountry = addressDictionary["Country"] as! String
                let location = "\(locationCountry)"
//                let location = "\(locationCity), \(locationCountry)"
                
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
            } else {
                println("Location: \(location)")
                
                // set the pin title
                let title = location!
                // create the annotation from coordinate
                self.addAnnotationToCoordinate(coordinate, location: title)
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
    }
}
