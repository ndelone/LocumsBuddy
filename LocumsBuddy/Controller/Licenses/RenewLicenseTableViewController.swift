//
//  RenewLicenseTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 5/13/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift

class RenewLicenseTableViewController: UITableViewController {
    
    let k = Constants()
    let realm = try! Realm()
    var selectedLicense : License?
    let renewalInfo = RenewalInfo()
    lazy var renewalDictionary = renewalInfo.medicalRenewalDictionary
    private var renewalCme : Int = 0
    private var renewalYears : Int = 0
    private var renewalWebsiteString  = ""
    @IBOutlet weak var cmeRequirementsCell: UITableViewCell!
    //    @IBOutlet weak var feeCell: UITableViewCell!
    @IBOutlet weak var websiteCell: UITableViewCell!
    @IBOutlet weak var dateRetrievedCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //print(indexPath.row)
        if indexPath.section == 1 {
            if let url = URL(string: renewalWebsiteString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func loadData(){
        if selectedLicense?.name == "Medical" {
            if let stateName = selectedLicense?.parentCategory.first?.name {
                let renewalArray = renewalDictionary[stateName]
                renewalCme = renewalArray?[0] as! Int
                renewalYears = renewalArray?[1] as! Int
                renewalWebsiteString = renewalArray?[2] as! String
            }
        }
        
        loadTableText()
    }
    
    func loadTableText(){
        let cmeEarned = getCME(timespan: selectedLicense!.renewalCMEYears)
        cmeRequirementsCell.textLabel?.numberOfLines = 0
        cmeRequirementsCell.textLabel?.font = k.textFont
        cmeRequirementsCell.textLabel?.attributedText = generateCMEString(cmeRequired: renewalCme, timespanCMEEarned: renewalYears)
        //        feeCell.textLabel?.text = String(format: "$%.02f", selectedLicense?.renewalFee ?? 0.0)
        //        feeCell.textLabel?.font = k.textFont
        //        feeCell.textLabel?.textColor = k.textColor
        websiteCell.textLabel?.text = renewalWebsiteString
        websiteCell.textLabel?.numberOfLines = 0
        websiteCell.textLabel?.textColor = k.textColor
        websiteCell.textLabel?.font = k.textFont
        dateRetrievedCell.textLabel?.text = "Information accurate as of \(renewalInfo.informationAccurateAsOf)"
        
    }
    
    func getCME(timespan: Int)->Int {
        var dateComponent = DateComponents()
        var cmeEarned = 0
        dateComponent.year = timespan * -1
        let timespanAsDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        let CMEList = realm.objects(CME.self).filter("issueDate >= %@", timespanAsDate)
        for CME in CMEList {
            cmeEarned += CME.creditType == "AMA PRA I" ?  CME.creditAmount : 0
        }
        return cmeEarned
    }
    
    
    //Creating a colorized CME string
    func generateCMEString(cmeRequired: Int, timespanCMEEarned: Int) -> NSMutableAttributedString {
        
        let cmeEarned = getCME(timespan: timespanCMEEarned)
        
        cmeRequirementsCell.textLabel?.textColor = cmeEarned < cmeRequired ? UIColor.systemRed : UIColor.systemGreen
        
        let greenFont = [NSAttributedString.Key.font : k.textFont, NSAttributedString.Key.foregroundColor : UIColor.green]
        
        let redFont = [NSAttributedString.Key.font : k.textFont, NSAttributedString.Key.foregroundColor : UIColor.red]
        
        let normalFont = [NSAttributedString.Key.font : k.textFont, NSAttributedString.Key.foregroundColor : k.textColor]
        
        let attributedString1 = NSMutableAttributedString(string:"\(cmeRequired)", attributes: cmeEarned < cmeRequired ? redFont : greenFont)
        
        let attributedString2 = NSMutableAttributedString(string: " CMEs are required over the past \(renewalYears) years. You have completed ", attributes: normalFont)
        
        let attributedString3 = NSMutableAttributedString(string:"\(cmeEarned)", attributes: cmeEarned < cmeRequired ? redFont : greenFont)
        
        let attributedString4 = NSMutableAttributedString(string:" in the past \(renewalYears) years.", attributes: normalFont)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        attributedString1.append(attributedString4)
        
        return attributedString1
    }
    
    
}
