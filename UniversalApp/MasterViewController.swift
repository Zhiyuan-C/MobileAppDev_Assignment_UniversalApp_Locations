//
//  MasterViewController.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//
import CoreLocation
import UIKit
import Foundation

class MasterViewController: UITableViewController {
    
    //MARK: - initialise varibles
    /// DetailViewController
    var detailViewController: DetailViewController? = nil
    /// places which contains array of Place
    var places = [Place]()
    /// flag to check if is edit mode
    var editPlaceFlag = false
    /// int for determine which row is selected to edit
    var selectedIndexRowForEdit: Int = 0
    /// initialise property list encoder
    let encoder = PropertyListEncoder()
    /// initilaise the path to save the plist
    let plistPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        // add item
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        // split view
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? AddPlaceViewController
//            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        // if the app is first time launch, create and save the plist
        if isFirstLaunch() {
            savePlist()
        }
        // read the plist data
        readPlist()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    

    
    // MARK: - Segues
    @objc
    /// perform segue way to display AddPlaceViewController
    ///
    /// - Parameter sender: self, MasterViewController
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "displayAddPlaceView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if identifier is showDetail, delegate to the detailViewController
        if segue.identifier == "displayAddPlaceView" {
            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = places[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                guard let addPlaceVC = (segue.destination as! UINavigationController).topViewController as? AddPlaceViewController else { return }
//                controller.placeDetail = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
                addPlaceVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                addPlaceVC.navigationItem.leftItemsSupplementBackButton = true
            } else {
                // reload if none select
                guard let splitController = self.splitViewController?.viewControllers else { return }
                self.detailViewController = splitController.last as? DetailViewController
            }
        }
        // if identifier is the displayAddPlaceView, delegate to the AddPlaceViewController
//        if segue.identifier == "displayAddPlaceView" {
//            guard let addPlaceVC = (segue.destination as! UINavigationController).topViewController as? AddPlaceViewController else { return }
//            addPlaceVC.addPlaceDelegate = self
//
//        }
    }

    // MARK: - Table View
    
    // how many rows to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    // display data to the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = places[indexPath.row]
        cell.textLabel?.text = object.placeName
        return cell
    }
    // allow to edit item
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Rearranging the item.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let place = places.remove(at: fromIndexPath.row)
        places.insert(place, at: toIndexPath.row)
    }
    
    // MARK: - Swipe actions
    
    // Perfomr swipe actions - edit and delete
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    /// Create delete action, to delete the item from table
    ///
    /// - Parameter indexPath: indexPath of the selected row
    /// - Returns: UIContextualAction
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.places.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.savePlist()
            // reload detail view when is in split mode
            if self.splitViewController?.viewControllers.count == 2 {
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }
            completion(true)
        }
        return action
    }
    
    /// Create edit action, to edit the item of selected row
    ///
    /// - Parameter indexPath: indexPath of the selected row
    /// - Returns: UIContextualAction
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.editPlaceFlag = true
            self.selectedIndexRowForEdit = indexPath.row
            self.performSegue(withIdentifier: "displayAddPlaceView", sender: self)
            completion(true)
        }
        action.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        return action
    }
    
    //MARK: - Persistence

    /// save the data as plisr
    func savePlist(){
        do {
            let propertyList = try encoder.encode(places)
            let savePlistURL = plistPath.appendingPathComponent("places.plist")
            try propertyList.write(to: savePlistURL, options: .atomic)
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// read the plist data
    func readPlist(){
        do {
            let savePlistURL = plistPath.appendingPathComponent("places.plist")
            let data = try Data(contentsOf: savePlistURL)
            let decoder = PropertyListDecoder()
            places = try decoder.decode([Place].self, from: data)
        } catch {
            print("Error: \(error)")
        }
    }
    // function to detect first launch
    /// Detect if the app is first time launch or not
    ///
    /// - Returns: Bool, true if is first time, false if is not first time
    func isFirstLaunch()->Bool{
        let userDefault = UserDefaults.standard
        if let _ = userDefault.string(forKey: "isFirstLaunch") {
            return false
        } else {
            userDefault.set(true, forKey: "isFirstLaunch")
            return true
        }
    }
    
}

//MARK: - AddPlaceVC Delegate
extension MasterViewController: AddPlaceVCDelegate {
    
    /// reload table view
    func reloadTableView(){
        tableView.reloadData()
    }
    
    /// Let view pop back to the MasterViewController
    func backToMaster(){
        guard let navigationViewControllers = self.navigationController?.viewControllers else { return }
        for controller in navigationViewControllers {
            if controller.isKind(of: MasterViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    /// append place to places
    ///
    /// - Parameter newPlace: new Place created in AddPlaceViewController
    func addPlace(newPlace: Place){
        places.append(newPlace)
        savePlist()
        backToMaster()
        reloadTableView()
    }
    
    /// Edit and save the place data, and then Pop view back to master, and reload the table view
    func editPlace(name: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        places[selectedIndexRowForEdit].placeAddress = address
        places[selectedIndexRowForEdit].placeName = name
        places[selectedIndexRowForEdit].placeLatitude = latitude
        places[selectedIndexRowForEdit].placeLongitude = longitude
        editPlaceFlag = false
        savePlist()
        backToMaster()
        reloadTableView()
        // reload detail view when is in split mode
        if self.splitViewController?.viewControllers.count == 2 {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
    
    /// return current selected object
    func currentPlace() -> Place {
        return places[selectedIndexRowForEdit]
    }
    
    /// return the flag status of the editing mode
    func isEdit() -> Bool {
        if editPlaceFlag {
            return true
        } else {
            return false
        }
    }
    
    /// set edit flag back to false if back to master view with the back button
    func falseEditFlag() {
        editPlaceFlag = false
    }
    
}

