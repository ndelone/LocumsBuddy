//
//  AlarmSideMenuTableController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/8/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit

class AlarmSideMenuTableController: UITableViewController {
    
    
    let alarmDictionary = [ ["None" : 0],["One day before" : 1], ["One week before" : 7],[ "Two weeks before" : 14], ["One month before" : 30]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmDictionary.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = alarmDictionary[indexPath.row].keys.first
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        weak var pvc = self.navigationController?.presentingViewController as? UINavigationController
        if let numberOfChildren = pvc?.viewControllers.count {
            let licenseVC = self.presentingViewController?.children[numberOfChildren - 1] as? LicenseViewController
            licenseVC?.tableView.reloadData()
            licenseVC?.alarmLabel.text = alarmDictionary[indexPath.row].keys.first
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
