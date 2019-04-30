//
//  AddPlaceViewController.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//

import UIKit
import CoreLocation
protocol AddPlaceVCDelegate: class {
    /// Reload table view
    func reloadTableView()
    
    /// Let view pop back to the MasterViewController
    func backToMaster()
    
    /// append place to places
    ///
    /// - Parameter newPlace: new Place created in AddPlaceViewController
    func addPlace(newPlace: Place)
    
    /// Pop view back to master, and reload the table view
    func editPlace(name: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    
    /// return current selected object
    func currentPlace() -> Place
    
    /// return the flag status of the editing mode
    func isEdit() -> Bool
    
    /// set edit flag back to false if back to master view with the back button
    func falseEditFlag()
}

class AddPlaceViewController: UITableViewController, UITextFieldDelegate {
    // initialise variables
    /// addPlace delegate
    weak var addPlaceDelegate: AddPlaceVCDelegate?
    /// flag to know if is edit mode or not
    var isEdit = false
    /// a Place data
    var placeData: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameInput.delegate = self
        placeAddressInput.delegate = self
        placeLatitudeInput.delegate = self
        placeLongitudeInput.delegate = self
        // if edit, then display place into text field
        guard let editStatus = addPlaceDelegate?.isEdit() else { return }
        if editStatus {
            displayPlace()
        }
        
        
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
              let latitude = CLLocationDegrees(latitudeText) else { return }
        guard let longitudeText = placeLongitudeInput.text,
              let longitude = CLLocationDegrees(longitudeText) else { return }
        isEdit = addPlaceDelegate?.isEdit() ?? false

        if isEdit {
            addPlaceDelegate?.editPlace(name: nameText, address: addressText, latitude: latitude, longitude: longitude)
        }
        // Create new place and add to places
        else {
            let newPlace = Place(placeName: nameText, placeAddress: addressText, placeLatitude: latitude, placeLongitude: longitude)
            addPlaceDelegate?.addPlace(newPlace: newPlace)
        }
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        addPlaceDelegate?.backToMaster()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        addPlaceDelegate?.reloadTableView()
        addPlaceDelegate?.falseEditFlag()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        
        // if user has enter place, then foward track the geolocation and display to the text field
        let placeAddress = placeAddressInput.text ?? ""
        if placeAddress != "" {
            getLocation(placeAddress: placeAddress)
        }
        
        return true
    }
    
    func getLocation(placeAddress: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(placeAddress){
            guard let placeMarks = $0 else {
                print("Got error: \(String(describing: $1))")
                return
            }
            print("Got \($0?.count ?? 0) elements:")
            for placeMark in placeMarks {
                guard let location = placeMark.location else {continue}
                print("Got \(location.coordinate) for \(placeAddress)")
                self.placeLatitudeInput.text = "\(location.coordinate.latitude)"
                self.placeLongitudeInput.text = "\(location.coordinate.longitude)"
                
            }
        }
        
    }
    
    /// display place into text field
    func displayPlace(){
        guard let place = addPlaceDelegate?.currentPlace() else { return }
        placeNameInput.text = place.placeName
        placeAddressInput.text = place.placeAddress
        placeLatitudeInput.text = "\(place.placeLatitude)"
        placeLongitudeInput.text = "\(place.placeLongitude)"
    }
    
}
