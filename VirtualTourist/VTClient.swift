//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/20/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import MapKit

class VTClient: NSObject {
    
    struct Flickr {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "fc536aa56220030faed87de0bc430240"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let PER_PAGE = "21"
        
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
        static let StatusMessage = "status_message"
    }
    
    // shared session
    var session: NSURLSession
    
    // initialize shared NSURL session
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance Singleton
    class func sharedInstance() -> VTClient {
        
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        return Singleton.sharedInstance
    }
    
    // Photo grab starts here. Get the page from the photos, then get the image in that page
    func getPhotosFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        
        let parameters = [
            "method": Flickr.METHOD_NAME,
            "api_key": Flickr.API_KEY,
            "bbox": createBoundingBoxString(coordinate),
            "safe_search": Flickr.SAFE_SEARCH,
            "extras": Flickr.EXTRAS,
            "format": Flickr.DATA_FORMAT,
            "nojsoncallback": Flickr.NO_JSON_CALLBACK,
            "per_page": Flickr.PER_PAGE
        ]
        taskForGETMethod(parameters, completionHandler: { (result, error) -> Void in
            if let error = error {
                println("Error in GET call: Get photos from coordinate")
                completionHandler(result: nil, error: error)
            } else {
                println("GET call succcess")

                // get a random page
                let randomPage = self.getRandomPageNumberFromDictionary(result)
                
                // get images from page
                self.getImageWithPage(parameters, pageNumber: randomPage, completionHandler: { (result, error) -> Void in
                    if let error = error {
                        println("Error in getImageWithPage call")
                        completionHandler(result: nil, error: error)
                    } else {
                        println("Success in getImageWithPage call")
                        completionHandler(result: result, error: nil)
                    }
                })
            }
        })
    }
    
    // Helper - get a random page number
    func getRandomPageNumberFromDictionary(result: AnyObject!) -> Int {
        if let photosDictionary = result.valueForKey("photos") as? [String:AnyObject] {
            
            if let totalPages = photosDictionary["pages"] as? Int {
                
                /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                
                return randomPage
                
            } else {
                println("Cant find key 'pages' in \(photosDictionary)")
            }
        } else {
            println("Cant find key 'photos' in \(result)")
        }
        return 0
    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: (result: [[String: AnyObject]]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Add the page to the method's arguments */
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        
        let task = taskForGETMethod(withPageDictionary, completionHandler: { (result, error) -> Void in
            if let error = error {
                println("Error in GET call: Get image from page")
                completionHandler(result: nil, error: error)
            } else {
                println("Success in GET call: Get image from page")
                let photosArray = self.parsePhotoDictionary(result)
                // TODO: pass photos array to completion
                completionHandler(result: photosArray, error: nil)
            }
        })
        return task
    }
    
    // Helper - create the array of [Photo]
    func parsePhotoDictionary(result: AnyObject!) -> [[String: AnyObject]] {
        if let photosDictionary = result["photos"] as? [String:AnyObject] {
            
            var totalPhotosVal = 0
            if let totalPhotos = photosDictionary["total"] as? String {
                totalPhotosVal = (totalPhotos as NSString).integerValue
            }
            
            if totalPhotosVal > 0 {
                if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                    println("Photos Array: \(photosArray.count)")
                    
                    return photosArray
                    
                } else {
                    println("Cant find key 'photo' in \(photosDictionary)")
                }
            } else {
                println("There's no photos")
            }
        } else {
            println("Cant find key 'photos' in \(result)")
        }
        return [[String: AnyObject]]()
    }
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        // Flickr image URL
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        
        // Make the request
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            if let error = downloadError {
                let newError = VTClient.errorForData(data, response: response, error: error)
                completionHandler(imageData: data, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        
        return task
    }
    
    // Generic GET method
    func taskForGETMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let session = NSURLSession.sharedSession()
        let urlString = Flickr.BASE_URL + VTClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
                let newError = VTClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                
                VTClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        task.resume()
        
        return task
    }
    
    // Helper - Make bounding box from coordinates
    func createBoundingBoxString(coordinate: CLLocationCoordinate2D) -> String {
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Flickr.BOUNDING_BOX_HALF_WIDTH, Flickr.LON_MIN)
        let bottom_left_lat = max(latitude - Flickr.BOUNDING_BOX_HALF_HEIGHT, Flickr.LAT_MIN)
        let top_right_lon = min(longitude + Flickr.BOUNDING_BOX_HALF_HEIGHT, Flickr.LON_MAX)
        let top_right_lat = min(latitude + Flickr.BOUNDING_BOX_HALF_HEIGHT, Flickr.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[VTClient.Flickr.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
}
