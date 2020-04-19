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

class RemindersTableViewController: UITableViewController {
    
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
        print("The licesnse to pass is \(selectedLicense)")
        destinationVC.oldLicense = selectedLicense
        destinationVC.displayType = ((selectedLicense?.licenseType == "DEA" || selectedLicense?.licenseType == "State") ? "State" : "National")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Configure the cell...
        let currentLicense = resultsList?[indexPath.row]
        var parentString = (currentLicense?.parentCategory.first?.name) ?? ""
        parentString += (parentString != "" ? " " : "" )
        if let expirationDate = currentLicense!.expirationDate, let licenseTypeString = currentLicense?.licenseType {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let expirationDateString = dateFormatterPrint.string(from: expirationDate)
            //Format strings differently based on time until expiration
            
            cell.textLabel?.font = UIFont(name: "Courier", size: 20)
            if let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day {
                switch diffInDays {
                case -10000 ... 0:
                    cell.textLabel?.text = "\(parentString)\(licenseTypeString) EXPIRED on \(expirationDateString)"
                    cell.textLabel?.textColor = UIColor.systemRed
                    cell.textLabel?.font = UIFont(name: "Courier-Bold", size: 20)
                case 1 ... 31:
                    cell.textLabel?.text = "\(parentString)\(licenseTypeString) expires on \(expirationDateString)"
                    cell.textLabel?.textColor = UIColor.systemYellow
                default:
                    cell.textLabel?.text = "\(parentString)\(licenseTypeString) expires on \(expirationDateString)"
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
        resultsList = realm.objects(License.self).filter("expirationDate != nil").sorted(byKeyPath: "expirationDate", ascending: true)
        tableView.reloadData()
    }
}
