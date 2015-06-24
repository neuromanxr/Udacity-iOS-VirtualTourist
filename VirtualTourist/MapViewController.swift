//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/18/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var gesture = UILongPressGestureRecognizer()
    
    var pins = [MapPin]()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fetchAllMapPins()
        
        self.loadMapDefaults()
        
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addGestureRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.mapView.removeGestureRecognizer(self.gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchAllMapPins() {
        
        // get all the map pins
        let error = NSErrorPointer()
        let fetchRequest = NSFetchRequest(entityName: "MapPin")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "", ascending: true)]
        let mapPins = self.sharedContext.executeFetchRequest(fetchRequest, error: error)
        println("Map Pins \(mapPins?.count)")
        
        // then show the pins on the map
        self.mapView.addAnnotations(mapPins)
        
    }
    
    func loadMapDefaults() {
        if let mapCenterLat = NSUserDefaults.standardUserDefaults().objectForKey(DefaultMapKeys.centerLat) as? Double {
            println("Map Defaults exist")
            let mapCenterLong = NSUserDefaults.standardUserDefaults().doubleForKey(DefaultMapKeys.centerLong)
            let mapSpanLat = NSUserDefaults.standardUserDefaults().doubleForKey(DefaultMapKeys.spanLat)
            let mapSpanLong = NSUserDefaults.standardUserDefaults().doubleForKey(DefaultMapKeys.spanLong)
            
            let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(mapCenterLat, mapCenterLong), MKCoordinateSpanMake(mapSpanLat, mapSpanLong))
            self.mapView.setRegion(region, animated: false)
        } else {
            println("Defaults don't exist")
        }
        
    }
    
}

