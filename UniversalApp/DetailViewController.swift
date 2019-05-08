//
//  DetailViewController.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//
import CoreLocation
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeLatitudeLabel: UILabel!
    @IBOutlet weak var placeLongitudeLabel: UILabel!
    
    
    
    /// display the data to the label
    func displayData() {
        // initialise
        guard let detail = placeDetail else { return }
        // display data
        if let nameLabel = placeNameLabel,
           let addressLabel = placeAddressLabel,
           let latitudeLabel = placeLatitudeLabel,
           let longitudeLabel = placeLongitudeLabel {
            nameLabel.text = detail.placeName
            addressLabel.text = detail.placeAddress
            latitudeLabel.text = "\(detail.placeLatitude)"
            longitudeLabel.text = "\(detail.placeLongitude)"
        } else { return }
    }

    override func viewDidLoad() {
        if self.splitViewController?.viewControllers.count == 2 {
            navigationItem.rightBarButtonItem = editButtonItem
        }
        super.viewDidLoad()
        displayData()
    }

    var placeDetail: Place? {
        didSet {
            // Update the view.
            displayData()
        }
    }
    
 
    
}
