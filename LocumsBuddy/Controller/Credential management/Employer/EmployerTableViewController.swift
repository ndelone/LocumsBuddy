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

class EmployerTableViewController: SwipeCellController {
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        generateAddAlert()
    }
    var selectedEmployer : Employer?
    let K = Constants()
    let realm = try! Realm()
    lazy var employerList = realm.objects(LicenseRepository.self).first?.employerList
    override func viewDidLoad() {
        super.viewDidLoad()
        //employerList = realm.objects(LicenseRepository.self).first?.employerList
    }
    
    //MARK: - Table methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Return selected state item
        selectedEmployer = employerList?[indexPath.row]
        //Perform segue
        performSegue(withIdentifier: "employerDetailSegue", sender: self)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return employerList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = employerList?[indexPath.row].name
        cell.textLabel?.textColor = K.textColor
        cell.textLabel?.font = K.textFont
        return cell
    }
    
    //MARK: - Add Button Pressed/Generate alert
    
    func generateAddAlert(){
        let alert = UIAlertController(title: "Add an employer", message: "", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Enter employer name"
        }
        let okay = UIAlertAction(title: "Add", style: .default) { (okay) in
            //Add Employer
            print(textField.text!)
            if textField.text != "" {
                self.addNewEmployer(textField.text!)
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
    
    
    func addNewEmployer(_ employerName : String){
        do {
            try realm.write {
                let newEmployer = Employer()
                newEmployer.name = employerName
                employerList?.append(newEmployer)
            }
        } catch {
            print("Failed to add employer")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete employer in realm
        print("Deleting employer in realm")
        
        do {
            try realm.write {
                if let employerToDelete = employerList?[indexPath.row] {
                    realm.delete(employerToDelete)
                }
            }
        } catch {
            print("error deleting employer")
        }
    }
    
    //MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! EmployerDetailTableViewController
        destinationVC.title = selectedEmployer?.name
        destinationVC.selectedEmployer = selectedEmployer
    }

}
