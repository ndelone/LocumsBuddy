//
//  RemindersTableViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/9/20.
//  Copyright © 2020 ND. All rights reserved.
//
import SwipeCellKit
import UIKit
import RealmSwift

class RemindersTableViewController: SwipeCellController {
    
    /*
     Class outline
     
     //Grab a list of all licenses that have expiration dates that are >= today
     //List expired licesnses
     //Display those licenses in order of  pending expiration
     //Maybe, if expiration has alarm show a little bell next to it?
     //Bell allows folks to delete it?
     */
    
    
    
    let realm = try! Realm()
    var resultsList : Results<License>?
    var selectedLicense : License?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadExpiringLicenses()
    }
    
    
    //MARK: - TableView Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLicense = resultsList?[indexPath.row]
        performSegue(withIdentifier: "licenseSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LicenseViewController
        print("The license to pass is \(selectedLicense)")
        destinationVC.selectedLicense = selectedLicense
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Hide reminder") { action, indexPath in
            // handle action by updating model with deletion

            self.updateModel(at: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Configure the cell...
        let currentLicense = resultsList?[indexPath.row]
        var parentString = (currentLicense?.parentCategory.first?.name) ?? ""
        parentString = (parentString == "National" ? "" : "\(parentString) " )
        if let expirationDate = currentLicense!.expirationDate, let licenseNameString = currentLicense?.name {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let expirationDateString = dateFormatterPrint.string(from: expirationDate)
            //Format strings differently based on time until expiration
            
            cell.textLabel?.font = UIFont(name: "Courier", size: 20)
            if let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day {
                switch diffInDays {
                case -10000 ... 0:
                    cell.textLabel?.text = "\(parentString)\(licenseNameString) license EXPIRED on \(expirationDateString)"
                    cell.textLabel?.textColor = UIColor.systemRed
                    cell.textLabel?.font = UIFont(name: "Courier-Bold", size: 20)
                case 1 ... 31:
                    cell.textLabel?.text = "\(parentString)\(licenseNameString) license expires on \(expirationDateString)"
                    cell.textLabel?.textColor = UIColor.systemYellow
                default:
                    cell.textLabel?.text = "\(parentString)\(licenseNameString) license expires on \(expirationDateString)"
                    cell.textLabel?.textColor = UIColor.systemGreen
                }
            }
        } else {
            cell.textLabel?.text = "No scheduled reminders"
        }
        return cell
    }
    
    func loadExpiringLicenses(){
        //Load license list
        print("Retrieving license list")
        //Set Today's date
        let today = Calendar.current.startOfDay(for: Date())
        resultsList = realm.objects(License.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try realm.write {
                resultsList?[indexPath.row].showReminder = false
            }
        } catch {
            print("Couldn't change reminder")
        }
        
                resultsList = realm.objects(License.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
    }
}
