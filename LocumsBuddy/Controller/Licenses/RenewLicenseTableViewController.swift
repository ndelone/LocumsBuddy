//
//  RenewLicenseTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 5/13/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit

class RenewLicenseTableViewController: UITableViewController {
    
    var selectedLicense : License?
    @IBOutlet weak var cmeRequirementsCell: UITableViewCell!
    @IBOutlet weak var feeCell: UITableViewCell!
    @IBOutlet weak var websiteCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData(){
        cmeRequirementsCell.textLabel?.text = "\(selectedLicense!.renewalCMEs) CMEs are required over the past \(selectedLicense!.renewalCMEYears) years."
        cmeRequirementsCell.textLabel?.numberOfLines = 0
        feeCell.textLabel?.text = String(format: "$%.02f", selectedLicense?.renewalFee ?? 0.0)
        websiteCell.textLabel?.text = selectedLicense?.renewalURLString
        websiteCell.textLabel?.numberOfLines = 0
    }
    
}
