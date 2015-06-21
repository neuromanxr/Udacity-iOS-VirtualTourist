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
    
    func getPhotosFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        
        let parameters = [
            "method": Flickr.METHOD_NAME,
            "api_key": Flickr.API_KEY,
            "bbox": createBoundingBoxString(coordinate),
            "safe_search": Flickr.SAFE_SEARCH,
            "extras": Flickr.EXTRAS,
            "format": Flickr.DATA_FORMAT,
            "nojsoncallback": Flickr.NO_JSON_CALLBACK
        ]
        taskForGETMethod(parameters, completionHandler: { (result, error) -> Void in
            if let error = error {
                println("Error in GET call")
                completionHandler(result: nil, error: error)
            } else {
                println("GET call succcess \(result)")
                
//                completionHandler(result: result, error: nil)
            }
        })
    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func taskForGETMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
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
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    if let totalPages = photosDictionary["pages"] as? Int {
                        
                        /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                        let pageLimit = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//                        self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)
                        
                    } else {
                        println("Cant find key 'pages' in \(photosDictionary)")
                    }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        task.resume()
    }
    
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
