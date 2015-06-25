//
//  MapPin.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/19/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@objc(MapPin)

class MapPin: NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Title = "Title"
        static let Latitude = "Lat"
        static let Longitude = "Long"
    }
    
    @NSManaged var title: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    
    var locationCoordinate = CLLocationCoordinate2D()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            locationCoordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)
            
            return locationCoordinate
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
        
        locationCoordinate = newCoordinate
        println("New Coordinate: \(newCoordinate.latitude), \(newCoordinate.longitude)")
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("MapPin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = dictionary[Keys.Title] as! String
        self.latitude = dictionary[Keys.Latitude] as! Double
        self.longitude = dictionary[Keys.Longitude] as! Double
        
        println("Pin inserted in context")
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
}
