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
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.draggable = true
                view.animatesDrop = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
                
                let deleteButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
                deleteButton.frame = CGRectMake(0, 0, 20, 20)
                deleteButton.setImage(UIImage(named: "deleteIcon"), forState: UIControlState.Normal)
                view.leftCalloutAccessoryView = deleteButton
                
                
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("Pin selected \(view.annotation)")
        
        // get the pin selected
        let pin = view.annotation as! MapPin
        
        // prefetch photos
        prefetchPhotosForPin(pin)
        
        centerMapOnPin(pin)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePhoto" {
            let photoCollectionController = segue.destinationViewController.topViewController as! PhotoCollectionViewController
            let pin = sender as! MapPin
            photoCollectionController.pin = pin
            
            
        }
    }
    
    func prefetchPhotosForPin(pin: MapPin) {
        // only fetch if photos is empty
        if pin.photos.isEmpty {
            
            VTClient.sharedInstance().getPhotosFromCoordinate(pin.coordinate, completionHandler: { (result, error) -> Void in
                if let error = error {
                    println("Error: In MapView")
                } else {
                    println("Result: \(result?.count)")
                    
                    let photosArray = result!
                    var photos = photosArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        // establish relationship with photo to selected pin
                        photo.pin = pin
                        
                        // fetch photos
                        VTClient.sharedInstance().taskForImage(photo.link!, completionHandler: { (imageData, error) -> Void in
                            if let error = error {
                                println("Prefetch: error")
                            } else {
                                if let data = imageData {
                                    photo.image = UIImage(data: data)
                                    photo.isDownloaded = true
                                } else {
                                    println("Store Image: error")
                                }
                            }
                        })
                        
                        return photo
                    }
                    
                }
            })
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func deletePinLocation(pin: MapPin) {
        self.mapView.removeAnnotation(pin)
        for photo in pin.photos {
            VTClient.Store.imageStore.deleteImage(photo.image, withIdentifier: photo.id!)
        }
        
        self.sharedContext.deleteObject(pin)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func handlePinDrag(annotation: MKAnnotation) {
        let pin = annotation as! MapPin
        getLocationFromCoordinate(pin.coordinate, withCompletion: { (location, error) -> () in
            if let error = error {
                println("Error: Getting location from coordinate")
            } else {
                pin.title = location!
            }
        })
        for pin in pin.photos {
            sharedContext.deleteObject(pin)
        }
        println("Pin Photos: \(pin.photos.count)")
        self.prefetchPhotosForPin(pin)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        // get the annotation tapped
        let pin = view.annotation as? MapPin
        println("Map Pin \(pin?.latitude), \(pin?.longitude)")
        
        if control == view.rightCalloutAccessoryView {
            // Show flickr images on right call out
            self.performSegueWithIdentifier("SeguePhoto", sender: pin)
            
            
        } else if control == view.leftCalloutAccessoryView {
            
            let alertController = UIAlertController(title: "Delete", message: "Delete pin?", preferredStyle: UIAlertControllerStyle.Alert)
            let alertActionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (actionOK) -> Void in
                // Delete annotation and location on left call out
                self.deletePinLocation(pin!)
            })
            let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (actionCancel) -> Void in
                println("Cancelled")
            })
            alertController.addAction(alertActionOK)
            alertController.addAction(alertActionCancel)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    // Update location when pin is dragged
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {

        switch (newState) {
        case .Starting:
            println("Pin dragging")
        case .Ending, .Canceling:
            println("Pin dragging ended: \(view.annotation.coordinate.latitude), \(view.annotation.coordinate.longitude)")
            handlePinDrag(view.annotation)
            
        default:
            break
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("Region did changed")
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
