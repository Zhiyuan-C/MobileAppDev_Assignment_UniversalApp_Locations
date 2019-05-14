//
//  AddPlaceViewController.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
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
    // MARK: - initialise variables
    /// addPlace delegate
    weak var addPlaceDelegate: AddPlaceVCDelegate?
    /// flag to know if is edit mode or not
    var isEdit = false
    /// a Place data
    var placeData: Place?
    
    // MARK: - IBOutlets
    @IBOutlet weak var placeNameInput: UITextField!
    @IBOutlet weak var placeAddressInput: UITextField!
    @IBOutlet weak var placeLatitudeInput: UITextField!
    @IBOutlet weak var placeLongitudeInput: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameInput.delegate = self
        placeAddressInput.delegate = self
        placeLatitudeInput.delegate = self
        placeLongitudeInput.delegate = self
        // if edit, then display place into text field
//        guard let editStatus = addPlaceDelegate?.isEdit() else { return }
//        print("editStatus => \(editStatus)")
//        if editStatus {
//            displayPlace()
//        }
        if isEdit {
            displayPlace()
        }
        
        
        
//        if self.splitViewController?.viewControllers.count == 2 {
//            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createNewPlace(_:)))
//            navigationItem.leftBarButtonItem = doneButton
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addPlaceDelegate?.reloadTableView()
        addPlaceDelegate?.falseEditFlag()
        isEdit = false
    }
    
    // MARK: - IBAction
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
        // edit the place
//        isEdit = addPlaceDelegate?.isEdit() ?? false
//        print("isEdit => \(isEdit)")
        if isEdit {
            addPlaceDelegate?.editPlace(name: nameText, address: addressText, latitude: latitude, longitude: longitude)
        }
        // Create new place and add to places
        else {
            let newPlace = Place(placeName: nameText, placeAddress: addressText, placeLatitude: latitude, placeLongitude: longitude)
            addPlaceDelegate?.addPlace(newPlace: newPlace)
        }
        
    }
    
    /// Perform action when user tap the cancel button
    ///
    /// - Parameter sender: Any
    @IBAction func cancelTapped(_ sender: Any) {
        addPlaceDelegate?.backToMaster()
        if self.splitViewController?.viewControllers.count == 2 {
            displayPlace()
        }
    }
    
    // MARK: - UITextFieldDelegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createNewPlace(_:)))
        navigationItem.leftBarButtonItem = doneButton
        // if user has enter place, then foward track the geolocation and display to the text field
        if textField.accessibilityIdentifier == "addressText" {
            let placeAddress = textField.text ?? ""
            if placeAddress != "" {
                getLocation(placeAddress: placeAddress)
            }
        }
        // revertrack
        if textField.accessibilityIdentifier == "latitudeText" || textField.accessibilityIdentifier == "longitudeText" {
            print("get name")
            let placeLatitude = placeLatitudeInput.text ?? ""
            let placeLongtitude = placeLongitudeInput.text ?? ""
            if placeLatitude != "" && placeLongtitude != "" {
                let location = convertLocation(latitudeText: placeLatitude, longitudeText: placeLongtitude)
                getName(latitude: location.latitude, longitude: location.longitude)
            }
        }
        
        
        return true
    }
    
    // MARK: - Custom functions to display value
    /// Get the location coodinate by the name of the address and display to the text field
    ///
    /// - Parameter placeAddress: address of the place provide by the user
    func getLocation(placeAddress: String){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(placeAddress){
            guard let placeMarks = $0 else {
                print("Error for geocode: \(String(describing: $1))")
                return
            }
            var current = CLLocation()
            for placeMark in placeMarks {
                guard let currentLocation = placeMark.location else {continue}
                current = currentLocation
                self.placeLatitudeInput.text = "\(currentLocation.coordinate.latitude)"
                self.placeLongitudeInput.text = "\(currentLocation.coordinate.longitude)"
            }
            self.displayLocation(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude, placeName: self.placeAddressInput.text ?? "")
        }
    }
    
    func getName(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location){
            guard let places = $0 else {
                print("Error-> \(String(describing: $1))")
                return
            }
            for place in places {
                let name = place.name ?? ""
                let postalCode = place.postalCode ?? ""
                let subLocality = place.subLocality ?? ""
                let administrativeArea = place.administrativeArea ?? ""
                let locality = place.locality ?? ""
                self.placeNameInput.text = "\(name)"
                self.placeAddressInput.text = "\(name), \(subLocality), \(locality), \(administrativeArea), \(postalCode)"
                // 593 Boundary Street, Brisbane, Spring Hill, QLD, 4000
                /*
                country => Australia
                name => 593 Boundary Street
                postalCode => 4000
                locality => Spring Hill
                subLocality => Brisbane
                administrativeArea => QLD
                subAdministrativeArea =>
                subThoroughfare => 593
                thoroughfare => Boundary Street
                */
            }
            self.displayLocation(latitude: latitude, longitude: longitude, placeName: self.placeAddressInput.text ?? "")
        }
    }
    
    /// display place data into text field
    func displayPlace(){
        guard let place = addPlaceDelegate?.currentPlace() else { return }
        placeNameInput.text = place.placeName
        placeAddressInput.text = place.placeAddress
        placeLatitudeInput.text = "\(place.placeLatitude)"
        placeLongitudeInput.text = "\(place.placeLongitude)"
        displayLocation(latitude: place.placeLatitude, longitude: place.placeLongitude, placeName: place.placeName)
    }
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, placeName: String){
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationRegion = MKCoordinateRegion(center: location, latitudinalMeters: 5_000, longitudinalMeters: 5_000)
        map.setRegion(locationRegion, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = placeName
            annotation.subtitle = "\(location.latitude), \(location.longitude)"
//            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            self.map.addAnnotation(annotation)
        }
        
    }
    
    func convertLocation(latitudeText: String, longitudeText: String) -> CLLocationCoordinate2D{
        let latitude: CLLocationDegrees = CLLocationDegrees(latitudeText) ?? 0.0
        let longitude: CLLocationDegrees = CLLocationDegrees(longitudeText) ?? 0.0
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return location
    }
    
    
}
