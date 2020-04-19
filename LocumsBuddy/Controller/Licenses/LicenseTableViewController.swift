//
//  LicenseTableViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift

class LicenseTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var displayType : String = "National"
    var selectedState : State?{
        didSet {
            displayType = "State"
        }
    }
var licenseType : String?
var cellArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArray()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return selectedState?.licenseList.count ?? 1
        return cellArray.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell.textLabel?.text = selectedState?.licenseList[indexPath.row].licenseType ?? "No license types added yet"
        cell.textLabel?.text = cellArray[indexPath.row] ?? "No licenses added yet"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        licenseType =   tableView.cellForRow(at: indexPath)?.textLabel?.text
        //selectedState?.licenseList[indexPath.row].licenseType
        performSegue(withIdentifier: "licenseDataSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LicenseViewController
        destinationVC.selectedState = selectedState
        destinationVC.licenseType = licenseType ?? "Default"
        destinationVC.displayType = displayType
        destinationVC.title = licenseType
    }

    func loadArray(){
        switch displayType {
        case "State":
            guard let licenseList = selectedState?.licenseList else {return}
            for license in licenseList{
                cellArray.append(license.licenseType)
            }

        case "National":
            guard let nationalList = realm.objects(LicenseRepository.self).first?.nationalLicenseList else { return }
            for license in nationalList{
                cellArray.append(license.licenseType)
            }
        default:
            print("Error choosing display type")
        }
    }
    

    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
