//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/18/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "PhotoCollectionCell"

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // the pin where the photos are associated with
    var pin: MapPin!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        // Navigation Buttons
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismiss")
        
        // Bottom Button
        self.bottomButton.enabled = false
        self.bottomButton.title = "New Collection"
        
        // Start activity indicator
        self.activityIndicator.startAnimating()
        
        println("Pin in PhotoCollection: \(self.pin)")
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        
        println("Fetched Objects: \(self.fetchedResultsController.fetchedObjects?.count)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Layout the collection view
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: {
            
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        var cellImage = UIImage(named: "placeholder")
        println("Pin Image \(cellImage!)")
        cell.imageView?.image = nil
        
        if photo.image != nil {
            cellImage = photo.image
        } else {
            
            cell.activityIndicator.startAnimating()
            
            let task = VTClient.sharedInstance().taskForImage(photo.link!, completionHandler: { (imageData, error) -> Void in
                if let error = error {
                    println("Error: taskForImage call")

                } else {
                    
                    if let data = imageData {
                        let image = UIImage(data: data)
                        photo.image = image
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.activityIndicator.stopAnimating()
                            cell.imageView?.image = image
                            photo.isDownloaded = true
                            
                            
                            
                            self.updateBottomButton()
                        })
                    } else {
                        println("Error: Couldn't get the image data")
                        
                    }
                }
            })
            
            cell.taskToCancelifCellIsReused = task
        }
        cell.imageView?.image = cellImage
        
        // stop activity indicators
        if cell.activityIndicator.isAnimating() {
            cell.activityIndicator.stopAnimating()
        }
        
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }
        
        // If the cell is "selected" it's color panel is grayed out
        // we use the Swift `find` function to see if the indexPath is in the array
        
        if let index = find(selectedIndexes, indexPath) {
            cell.imageView?.alpha = 0.2
        } else {
            cell.imageView?.alpha = 1.0
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return self.fetchedResultsController.sections?.count ?? 0
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo

        println("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        self.configureCell(cell, atIndexPath: indexPath)
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
        updateBottomButton()
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        }()
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        println("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            println("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            println("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            println("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            println("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        println("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                // TODO: Causes infinite loop with photo.isDownloaded
//                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    // MARK: - Actions and Helpers
    
    func getNewPhotoCollection() {
        
        println("Get New: \(pin.photos.count)")
        if pin.photos.isEmpty {
            
            if !self.activityIndicator.isAnimating() {
                self.activityIndicator.startAnimating()
            }
            
            VTClient.sharedInstance().getPhotosFromCoordinate(pin.coordinate, completionHandler: { (result, error) -> Void in
                if let error = error {
                    println("Error: In MapView")
                } else {
                    println("Result: \(result)")
                    
                    let photosArray = result!
                    var photos = photosArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        // establish relationship with photo to selected pin
                        photo.pin = self.pin
                        
                        
                        return photo
                    }
                    
                }
            })
            CoreDataStackManager.sharedInstance().saveContext()
        }
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    @IBAction func bottomButtonTapped() {
        
        if selectedIndexes.isEmpty {
            
            deleteAllPhotos()
            bottomButton.enabled = false
            getNewPhotoCollection()
            
        } else {
            deleteSelectedPhotos()
            
        }
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
    }
    
    func checkPhotosIsDownloaded() {
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
        // array of photos where isDownloaded property is false
        let photosNotDownloaded = photos.filter {
            $0.isDownloaded == false
        }
        // there are photos not finished downloading
        if photosNotDownloaded.count > 0 {
            // disable the New Collection button
            bottomButton.enabled = false
        } else {
            // all photos are finished downloading
            bottomButton.enabled = true
            
        }
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
            bottomButton.enabled = true
        } else {
            bottomButton.title = "New Collection"
            
            checkPhotosIsDownloaded()
        }
    }

}
