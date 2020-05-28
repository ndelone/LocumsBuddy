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
    let K = Constants()
    let realm = try! Realm()
    var selectedState : State?
    var selectedLicense : License?
    var licenseName : String?
    var licenseList : Results<License>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLicenses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLicenses()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseList?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = licenseList?[indexPath.row].name ?? "No licenses added yet"
        cell.textLabel?.font = K.textFont
        cell.textLabel?.textColor = K.textColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLicense = licenseList?[indexPath.row]
        performSegue(withIdentifier: "licenseDataSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LicenseViewController
        destinationVC.selectedLicense = selectedLicense
        destinationVC.title = selectedLicense!.name
    }
    
    func loadLicenses(){
        licenseList = selectedState?.licenseList.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
}
