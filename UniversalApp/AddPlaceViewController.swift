//
//  AddPlaceViewController.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//

import UIKit

protocol AddPlaceVCDelegate: class {
    /// Reload table view
    func reloadTableView()
    
    /// append place to places
    ///
    /// - Parameter newPlace: new Place created in AddPlaceViewController
    func addPlace(newPlace: Place)
    
    /// Pop view back to master, and reload the table view
    func editPlace()
}

class AddPlaceViewController: UITableViewController, UITextFieldDelegate {
    // initialise variables
    /// addPlace delegate
    weak var addPlaceDelegate: AddPlaceVCDelegate?
    /// flag to know if is edit mode or not
    var edit = false
    /// a Place data
    var placeData: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameInput.delegate = self
        placeAddressInput.delegate = self
        placeLatitudeInput.delegate = self
        placeLongitudeInput.delegate = self
        // display place into text field
        displayPlace()
    }
    @IBOutlet weak var placeNameInput: UITextField!
    @IBOutlet weak var placeAddressInput: UITextField!
    @IBOutlet weak var placeLatitudeInput: UITextField!
    @IBOutlet weak var placeLongitudeInput: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    /// Perform action depend on add or edit
    ///
    /// - Parameter sender: Any
    @IBAction func createNewPlace(_ sender: Any) {
        // initialise
        let nameText = placeNameInput.text ?? ""
        let addressText = placeAddressInput.text ?? ""
        guard let latitudeText = placeLatitudeInput.text,
              let latitude = Double(latitudeText) else { return }
        guard let longitudeText = placeLongitudeInput.text,
              let longitude = Double(longitudeText) else { return }
        // if is edit mode
        if edit {
            placeData?.placeName = nameText
            placeData?.placeAddress = addressText
            placeData?.placeLatitude = latitude
            placeData?.placeLongitude = longitude
            addPlaceDelegate?.editPlace()
        }
        // Create new place and add to places
        else {
            let newPlace = Place(placeName: nameText, placeAddress: addressText, placeLatitude: latitude, placeLongitude: longitude)
            addPlaceDelegate?.addPlace(newPlace: newPlace)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addPlaceDelegate?.reloadTableView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        textField.clearsOnBeginEditing = true // clear text field when begin edit
        return true
    }
    
    /// display place into text field
    func displayPlace(){
        guard let place = placeData else { return }
        placeNameInput.text = place.placeName
        placeAddressInput.text = place.placeAddress
        placeLatitudeInput.text = "\(place.placeLatitude)"
        placeLongitudeInput.text = "\(place.placeLongitude)"
    }
    
}
