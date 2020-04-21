//
//  StateTableViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/6/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift
import McPicker

class StateTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    let K = Constants()
    let realm = try! Realm()
    var realmStatesForTable : Results<State>?
    var selectedState : State?
    var realmStatesForPicker : Results<State>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Table view data source
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStates()
    }
    
    //MARK: - Tableview Data methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = realmStatesForTable?[indexPath.row].name ?? ("Add a state to get started")
        cell.textLabel?.text == "Add a state to get started" ? (cell.isUserInteractionEnabled = false) : (cell.isUserInteractionEnabled = true)
        cell.textLabel?.textColor = K.textColor
        cell.textLabel?.font = K.textFont
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.selectedState = self.realmStatesForTable?[indexPath.row]
            //updateModel
            self.deleteState(state: self.selectedState!)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructiveAfterFill
        return options
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmStatesForTable?.count ?? 1
    }
    
    
    //MARK: - Transition to next table
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Return selected state item
        selectedState = realmStatesForTable?[indexPath.row]
        //Perform segue
        performSegue(withIdentifier: "licenseSegue", sender: self)
    }
    
    //Prepare for segue to pass over state item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LicenseTableViewController {
            destinationVC.selectedState = selectedState
            destinationVC.title = selectedState?.name
        }
    }
    
    //MARK: - Load States
    
    func loadStates() {
        if let statesForTable = realm.objects(LicenseRepository.self).first?.stateChoiceList.filter("shouldAppearInPicker == false && name != %@","National").sorted(byKeyPath: "name", ascending: true){
            realmStatesForTable = statesForTable.count > 0 ? statesForTable : nil
        }
        
        if let statesForPicker = realm.objects(LicenseRepository.self).first?.stateChoiceList.filter("shouldAppearInPicker == true").sorted(byKeyPath: "name", ascending: true){
            realmStatesForPicker = statesForPicker.count > 0 ? statesForPicker : nil
        }
        
        tableView.reloadData()
        print("Set realmstate object successfully")
        
    }
    
    //MARK: - Add Button
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var pickerArray : [String] = []
        var stateName = ""
        for state in realmStatesForPicker! {
            pickerArray.append(state.name)
        }
        
        McPicker.showAsPopover(data: [pickerArray], fromViewController: self, barButtonItem: sender) { [weak self] (selections: [Int : String]) -> Void in
            if let state = selections[0] {
                stateName = state
                self?.selectedState = self?.realm.objects(LicenseRepository.self).first?.stateChoiceList.filter("name == %@", stateName).first
                self?.createNewDirectory(stateName: stateName, parentDirectoryString: "")
                self?.switchShouldAppearValue()
                self?.loadStates()
            }
        }
    }
    
    func switchShouldAppearValue() {
        if let state = selectedState {
            do {
                try realm.write{
                    selectedState?.shouldAppearInPicker = !state.shouldAppearInPicker
                }
            } catch  {
                print("Error saving realm picker change")
            }
            
        }
    }
    
    
    func createNewDirectory( stateName: String, parentDirectoryString : String){
        
        //        let fileManager = FileManager.default
        let documentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("State Licenses")
        let imagesPath = documentsURL.appendingPathComponent(parentDirectoryString + stateName)
        do
        {
            try FileManager.default.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            print("imagesPath is \(imagesPath)")
            print("documentsURL is \(documentsURL)")
            //imagePath = imagesPath
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    func deleteState(state: State){
        //Put the state back into statepicker
        switchShouldAppearValue()
        do {
            try realm.write{
                //remove notification if exists
                //Check if any license has reminder set
                for license in state.licenseList {
                    if license.alarmText != "None" {
                        let manager = LocalNotificationManager()
                        let idString =  manager.makeLicenseIDString(selectedLicense: license)
                        manager.deleteNotification(id: idString)
                    }
                    //clear the associated license data
                    license.showReminder = true
                    license.licenseNumber = ""
                    license.expirationDate = nil
                    license.issueDate = nil
                    license.alarmText = "None"
                }
            }
        } catch {
            print("Error deleting state")
        }
        
        //delete state directory
        
        let documentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("State Licenses")
        let imagesPath = documentsURL.appendingPathComponent(state.name)
        do
        {
            try FileManager.default.removeItem(atPath: imagesPath.path)
            print("Destroying Image folder")
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    
    
}
