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
        generateAddAlert()
    }
    var selectedItem : HealthDocument?
    
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
        return cell
    }
    
    //MARK: - Add Button Pressed/Generate alert
    
    func generateAddAlert(){
        let alert = UIAlertController(title: "Add a health document", message: "", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Name of document"
        }
        let okay = UIAlertAction(title: "Add", style: .default) { (okay) in
            //Add Employer
            print(textField.text!)
            if textField.text != "" {
                self.addNewDocument(textField.text!)
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
            else {
                alert.message = "Please enter a name"
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(okay)
        present(alert, animated: true, completion: nil)
    }
    
    
    func addNewDocument(_ documentName : String){
        do {
            try! realm.write {
                let newDocument = HealthDocument()
                newDocument.name = documentName
                healthList?.append(newDocument)
            }
        } catch {
            print("Failed to add employer")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete employer in realm
        print("Deleting employer in realm")
        
        do {
            try! realm.write {
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
