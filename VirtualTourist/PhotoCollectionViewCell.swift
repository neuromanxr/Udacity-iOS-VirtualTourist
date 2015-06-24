//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Kelvin Lee on 6/18/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // Cancel download task when collection view cell is reused
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
