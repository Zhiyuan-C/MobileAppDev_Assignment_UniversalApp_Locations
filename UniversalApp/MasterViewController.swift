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
    let encoder = PropertyListEncoder()
    let fileDirct = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        // add item
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        // split view
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // call read func
//        if places.count > 0 {
//            read()
//        }
        read()
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
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = places[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.placeDetail = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
//         if identifier is the displayAddPlaceView, delegate to the AddPlaceViewController
        else if segue.identifier == "displayAddPlaceView" {
            guard let addPlaceVC = (segue.destination as! UINavigationController).topViewController as? AddPlaceViewController else { return }
            addPlaceVC.addPlaceDelegate = self
//            if editPlaceFlag {
//                addPlaceVC.edit = true
//                addPlaceVC.placeData = places[selectedIndexRowForEdit]
//            }
//            editPlaceFlag = false
        }
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
            self.save()
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
    // experiment with persistence
    // create propertyListEncoder
    
    
    func save(){
        do {
            let propertyList = try encoder.encode(places)
            let fileSaveURL = fileDirct.appendingPathComponent("places.plist")
            print(fileSaveURL)
            // write
            try propertyList.write(to: fileSaveURL, options: .atomic)
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    func read(){
        do {
            // read
            let fileSaveURL = fileDirct.appendingPathComponent("places.plist")
            let data = try Data(contentsOf: fileSaveURL)
            let decoder = PropertyListDecoder()
            places = try decoder.decode([Place].self, from: data)
            print("Got \(places.count) places: \(places)")
        } catch {
            print("Error: \(error)")
        }
    }
    // function to detect first launch
    func isFirstLaunch()->Bool{
        let userDefault = UserDefaults.standard
        if let _ = userDefault.string(forKey: "isFirstLaunch") {
            print("Not first time")
            return false
        } else {
            userDefault.set(true, forKey: "isFirstLaunch")
            print("is first time")
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
        save()
        backToMaster()
        reloadTableView()
    }
    
    /// Pop view back to master, and reload the table view
    func editPlace(name: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        places[selectedIndexRowForEdit].placeAddress = address
        places[selectedIndexRowForEdit].placeName = name
        places[selectedIndexRowForEdit].placeLatitude = latitude
        places[selectedIndexRowForEdit].placeLongitude = longitude
        editPlaceFlag = false
        save()
        backToMaster()
        reloadTableView()
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

