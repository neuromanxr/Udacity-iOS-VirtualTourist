//
//  Photo.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/19/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Link = "url_m"
        static let Downloaded = "isDownloaded"

    }
    
    @NSManaged var id: String?
    @NSManaged var link: String?
    @NSManaged var isDownloaded: Bool
    @NSManaged var pin: MapPin?
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = dictionary[Keys.ID] as? String
        self.link = dictionary[Keys.Link] as? String
        self.isDownloaded = false
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    var image: UIImage? {
        get {
            return VTClient.Caches.imageCache.imageWithIdentifier(id!)
        }
        
        set {
            // store the image
            VTClient.Caches.imageCache.storeImage(newValue, withIdentifier: id!)
        }
    }
}
