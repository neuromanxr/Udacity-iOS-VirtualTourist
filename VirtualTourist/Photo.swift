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
        static let InAlbum = "InAlbum"
        static let Link = "Link"
        static let Image = "Image"
    }
    
    @NSManaged var link: String
    @NSManaged var inAlbum: Bool
    @NSManaged var image: NSData
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.link = dictionary[Keys.Link] as! String
        self.inAlbum = dictionary[Keys.InAlbum] as! Bool
        self.image = dictionary[Keys.Image] as! NSData
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
