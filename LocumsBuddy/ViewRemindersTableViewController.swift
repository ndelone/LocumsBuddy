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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExpiringLicenses()
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsList?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Configure the cell...
        let currentLicense = resultsList?[indexPath.row]
        let parentString = (currentLicense?.parentCategory.first?.name) ?? ""
        if let expirationDate = currentLicense!.expirationDate, let licenseTypeString = currentLicense?.licenseType {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let expirationDateString = dateFormatterPrint.string(from: expirationDate)
            cell.textLabel?.text = "\(parentString) \(licenseTypeString) expires on \(expirationDateString)"
        } else {
            cell.textLabel?.text = "No scheduled reminders"
        }
                //cell.accessoryType = (currentLicense?.isReminderSet == true ?  .detailDisclosureButton : .none) // Commenting out accessorry for cell...don't have a use for it now
        
        return cell
    }
    
    func loadExpiringLicenses(){
        //Load license list
        print("Retrieving license list")
        //Set Today's date
        let today = Calendar.current.startOfDay(for: Date())
        resultsList = realm.objects(License.self).filter("expirationDate >= %@", today).sorted(byKeyPath: "expirationDate", ascending: true)
        tableView.reloadData()
    }
}
