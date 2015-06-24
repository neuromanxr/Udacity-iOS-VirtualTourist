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
    
    var coordinate: CLLocationCoordinate2D {
        get {
            var coordinate = CLLocationCoordinate2D()
            coordinate.latitude = self.latitude.doubleValue
            coordinate.longitude = self.longitude.doubleValue
            return coordinate
        }
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
