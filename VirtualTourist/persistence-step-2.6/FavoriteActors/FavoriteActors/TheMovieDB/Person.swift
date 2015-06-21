//
//  Person.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit

// NOTE: - The Person class now extends NSObject, and conforms to NSCoding

class Person : NSObject, NSCoding {
 
    struct Keys {
        static let Name = "name"
        static let ProfilePath = "profile_path"
        static let Movies = "movies"
        static let ID = "id"
    }
    
    var name = ""
    var id = 0
    var imagePath = ""
    var movies = [Movie]()
    
    init(dictionary: [String : AnyObject]) {
        name = dictionary[Keys.Name] as! String
        id = dictionary[TheMovieDB.Keys.ID] as! Int
        
        if var pathForImgage = dictionary[Keys.ProfilePath] as? String {
            imagePath = pathForImgage
        }
    }
    
    var image: UIImage? {
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }
    
    
    // MARK: - NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        
        // archive the information inside the Person, one property at a time
        archiver.encodeObject(name, forKey: Keys.Name)
        archiver.encodeObject(id, forKey: Keys.ID)
        archiver.encodeObject(imagePath, forKey: Keys.ProfilePath)
        archiver.encodeObject(movies, forKey: Keys.Movies)
    }

    required init(coder unarchiver: NSCoder) {
        super.init()
        
        // Unarchive the data, one property at a time
        name = unarchiver.decodeObjectForKey(Keys.Name) as! String
        id = unarchiver.decodeObjectForKey(Keys.ID) as! Int
        imagePath = unarchiver.decodeObjectForKey(Keys.ProfilePath) as! String
        movies = unarchiver.decodeObjectForKey(Keys.Movies) as! [Movie]
    }
}


