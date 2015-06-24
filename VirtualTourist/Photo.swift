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
        static let Link = "url_m"
        static let Downloaded = "isDownloaded"
//        static let Image = "Image"
    }
    
    @NSManaged var link: String?
    @NSManaged var isDownloaded: Bool
//    @NSManaged var imageData: NSData?
    @NSManaged var pin: MapPin?
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.link = dictionary[Keys.Link] as? String
        self.isDownloaded = false
//        self.inAlbum = dictionary[Keys.InAlbum] as! Bool
//        self.imageData = dictionary[Keys.Image] as! NSData
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        self.image = nil
    }
    
    var image: UIImage? {
        get {
            return VTClient.Caches.imageCache.imageWithIdentifier(link)
        }
        
        set {
            VTClient.Caches.imageCache.storeImage(image, withIdentifier: link!)
        }
    }
}
