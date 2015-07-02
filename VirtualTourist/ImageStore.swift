//
//  ImageStore.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 7/1/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit

class ImageStore {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSFileManager.defaultManager().contentsAtPath(path) {
                return UIImage(data: data)
            } else {
                println("ImageStore: Data doesn't exist in path")
            }
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // store in cache
        if inMemoryCache.objectForKey(path) == nil {
            inMemoryCache.setObject(image!, forKey: path)
        }
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: - Delete images
    func deleteImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        var error: NSError?
        // delete the file
        NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        // delete the cache
        if inMemoryCache.objectForKey(path) != nil {
            inMemoryCache.removeObjectForKey(path)
        }
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        println("Path:\(fullURL.path!)")
        
        return fullURL.path!
    }
}
