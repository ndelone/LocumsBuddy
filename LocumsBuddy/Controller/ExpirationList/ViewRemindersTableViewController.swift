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
    var licenseResultsList : Results<License>?
    var healthResultsList : Results<HealthDocument>?
    var selectedLicense : License?
    var selectedHealthDocument : HealthDocument?
    let sectionNames = ["Licenses","Health Documents"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadExpirationLists()
    }
    
    
    //MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return licenseResultsList?.count ?? 1
        default:
            return healthResultsList?.count ?? 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedLicense = licenseResultsList?[indexPath.row]
            performSegue(withIdentifier: "licenseSegue", sender: self)
        case 1:
            selectedHealthDocument = healthResultsList?[indexPath.row]
            performSegue(withIdentifier: "healthSegue", sender: self)
        default:
            print("Default table selection")
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "licenseSegue":
            let destinationVC = segue.destination as! LicenseViewController
            destinationVC.selectedLicense = selectedLicense
        case "healthSegue":
            let destinationVC = segue.destination as! HealthDetailTableViewController
            destinationVC.selectedDocument = selectedHealthDocument
        default:
            print("Default preparation for segue")
        }

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
        var cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.font = UIFont(name: "Courier", size: 20)
        // Configure the cell...
        switch (indexPath.section){
        case 0:
            let currentLicense = licenseResultsList?[indexPath.row]
            var parentString = (currentLicense?.parentCategory.first?.name) ?? ""
            parentString = (parentString == "National" ? "" : "\(parentString) " )
            if let expirationDate = currentLicense!.expirationDate, let licenseNameString = currentLicense?.name {
                let documentName = "\(parentString)\(licenseNameString) license"
                cell = colorCodeCell(expirationDate: expirationDate, cell: cell, documentString: documentName)
            } else {
                cell.textLabel?.text = "No scheduled reminders"
            }
        case 1:
            let currentHealthDocument = healthResultsList?[indexPath.row]
            if let expirationDate = currentHealthDocument?.expirationDate, let documentName = currentHealthDocument?.name{
                cell = colorCodeCell(expirationDate: expirationDate, cell: cell, documentString: documentName)
            } else {
                cell.textLabel?.text = "No scheduled reminders"
            }
        default:
            cell.textLabel?.text = "No scheduled reminders"
        }
        
        return cell
    }
    
    func loadExpirationLists(){
        //Load license list
        print("Retrieving license list")
        //Set Today's date
        let today = Calendar.current.startOfDay(for: Date())
        licenseResultsList = realm.objects(License.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
        healthResultsList = realm.objects(HealthDocument.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try realm.write {
                switch indexPath.section {
                case 0:
                    licenseResultsList?[indexPath.row].showReminder = false
                    licenseResultsList = realm.objects(License.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
                case 1:
                    healthResultsList?[indexPath.row].showReminder = false
                    healthResultsList = realm.objects(HealthDocument.self).filter("expirationDate != nil && showReminder == true").sorted(byKeyPath: "expirationDate", ascending: true)
                default:
                    print("Default updateModel in View Reminders")
                }
            }
        } catch {
            print("Couldn't change reminder")
        }
    }
    
    
    func colorCodeCell(expirationDate: Date, cell: UITableViewCell, documentString: String) -> UITableViewCell {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
        let expirationDateString = dateFormatterPrint.string(from: expirationDate)
        if let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day {
            switch diffInDays {
            case -10000 ... 0:
                cell.textLabel?.text = "\(documentString) EXPIRED on \(expirationDateString)"
                cell.textLabel?.textColor = UIColor.systemRed
                cell.textLabel?.font = UIFont(name: "Courier-Bold", size: 20)
            case 1 ... 31:
                cell.textLabel?.text = "\(documentString) expires on \(expirationDateString)"
                cell.textLabel?.textColor = UIColor.systemYellow
            default:
                cell.textLabel?.text = "\(documentString) expires on \(expirationDateString)"
                cell.textLabel?.textColor = UIColor.systemGreen
            }
        }
        return cell
    }
}
