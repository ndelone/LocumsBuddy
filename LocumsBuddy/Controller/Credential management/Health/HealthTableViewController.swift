//
//  CredentialManagerTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/15/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class HealthTableViewController: SwipeCellController {
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        super.showAlert(title: "Add a health document", message: "Enter a unique name", placeHolder: "i.e. PPD 2020")
    }
    var selectedItem : HealthDocument?
    let K = Constants()
    let realm = try! Realm()
    lazy var healthList = realm.objects(LicenseRepository.self).first?.healthList
    override func viewDidLoad() {
        super.viewDidLoad()
        //healthList = realm.objects(LicenseRepository.self).first?.healthList
    }
    
    //MARK: - Table methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Return selected state item
        selectedItem = healthList?[indexPath.row]
        //Perform segue
        performSegue(withIdentifier: "healthDetailSegue", sender: self)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return healthList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = healthList?[indexPath.row].name
        cell.textLabel?.textColor = K.textColor
        cell.textLabel?.font = K.textFont
        return cell
    }
    
    //MARK: - Add Button Pressed/Generate alert

    
    @objc override func textChanged(_ sender:UITextField) {
        if sender.text! != "" {
            if ((healthList?.filter("name ==[cd] %@", sender.text!).count) ?? 0 == 0) {
                self.actionToEnable?.isEnabled = true
            } else {
                self.actionToEnable?.isEnabled = false
            }
        } else {
            self.actionToEnable?.isEnabled = true
        }
    }
    
    
    override func addNewItem(_ name: String) {
        do {
            try realm.write {
                let newDocument = HealthDocument()
                newDocument.name = name
                healthList?.append(newDocument)
            }
        } catch {
            print("Failed to add health document")
        }
        tableView.reloadData()
    }

    
    override func updateModel(at indexPath: IndexPath) {
        //Delete employer in realm
        print("Deleting health item in realm")
        
        do {
            //Delete notifications
            let notificationManager = LocalNotificationManager()
            let notificationID = notificationManager.makeHealthIDString(selectedHealth: healthList?[indexPath.row])
            notificationManager.deleteNotification(id: notificationID)
            
            try realm.write {
                if let documentToDelete = healthList?[indexPath.row] {
                    realm.delete(documentToDelete)
                }
            }
        } catch {
            print("error deleting employer")
        }
    }
    
    //MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! HealthDetailTableViewController
        destinationVC.title = selectedItem?.name
        destinationVC.selectedDocument = selectedItem
    }

}
