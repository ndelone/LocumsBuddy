//
//  LicenseViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift
import SideMenu

class LicenseViewController: PhotoViewClass{
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var savedLabel: UILabel!
    let manager = LocalNotificationManager()
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var issueDatePicker: UIDatePicker!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    @IBOutlet weak var licenseTextField: UITextField!
    let alarmDictionary = [ "None" : 0,"One day before" : 1, "One week before" : 7, "Two weeks before" : 14, "One month before" : 30]
    let realm = try! Realm()
    var selectedState : State?
    var licenseType : String = ""
    var displayType = ""
    var licenseToPass : License?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licenseTextField.delegate = self
        loadInformation()
        super.imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(licenseToPass!.savingPath)
        super.imageName = "\(licenseToPass!.licenseType).jpeg"
        super.loadImageView = imageView
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You pressed row \(indexPath.row)")
        if indexPath.row == 4 {
            super.saveButtonPressedDone()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Save Button
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        if inputPassesValidation() {
            saveLicense()
            if let days = alarmDictionary[alarmLabel.text!]{
                setNotification(days: days)
            }
            displaySaveBanner()
        }
        
    }
    //MARK: - Validate licenses input
    
    func validationAlert(alarmText : String){
        let alert = UIAlertController(title: alarmText, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func inputPassesValidation() -> Bool {
        //Check issue date is before today
        if issueDatePicker.date <= Date() {
            print("Issue date acceptable")
            //Check that expiration date is after issue date
            if expirationDatePicker.date>issueDatePicker.date {
                print("Expiration date acceptable")
                //Capture the alarm date
                if alarmDictionary[alarmLabel.text!]! == 0 {
                    return true
                } else {
                    var dateComponent = DateComponents()
                    dateComponent.day = alarmDictionary[alarmLabel.text!]! * -1
                    let reminderDate = Calendar.current.date(byAdding: dateComponent, to: Calendar.current.startOfDay(for: expirationDatePicker.date))
                    let today = Calendar.current.startOfDay(for: Date())
                    //Ensure alarm date is at least 2 days from current date
                    guard let diffInDays = Calendar.current.dateComponents([.day], from: today, to: reminderDate!).day else {return false}
                    print(diffInDays)
                    if diffInDays >= 2 {
                        print("Passed validation")
                        return true
                    } else {
                        validationAlert(alarmText: "Reminder needs to be at least 2 days from today.")
                    }
                }
            } else{
                validationAlert(alarmText: "Expiration date needs to be after issue date!")
            }
        } else {
            validationAlert(alarmText: "Issue date can't be in the future!")
        }
        
        return false
    }
    
    func saveLicense(){
        
        let newLicense = License()
        newLicense.licenseNumber = licenseTextField.text
        newLicense.issueDate = issueDatePicker.date
        newLicense.expirationDate = expirationDatePicker.date
        newLicense.licenseType = licenseType
        newLicense.isReminderSet = (alarmLabel.text == "None") ? false : true
        newLicense.alarmText = alarmLabel.text ?? "None"
        
        do {
            try realm.write{
                switch displayType {
                case "State":
                    guard let  oldLicense = selectedState?.licenseList.filter("licenseType == %@", licenseType).first else {return}
                    newLicense.savingPath = "State Licenses/\(selectedState!.name)"
                    selectedState?.licenseList.append(newLicense)
                    realm.delete(oldLicense)
                    licenseToPass = newLicense
                case "National":
                    print("National arc")
                    guard let  oldLicense = realm.objects(LicenseRepository.self).first?.nationalLicenseList.filter("licenseType == %@", licenseType).first else {return}
                    print(oldLicense.licenseType)
                    newLicense.savingPath = "National Licenses/\(licenseType)"
                    realm.objects(LicenseRepository.self).first?.nationalLicenseList.append(newLicense)
                    realm.delete(oldLicense)
                    licenseToPass = newLicense
                default:
                    print("error saving license")
                }
            }
        } catch {
            print("Error in writing new state license")
        }
    }
    
    //MARK: - Loading initial information
    
    func loadInformation(){
        var oldLicense : License?
        switch displayType {
        case "State":
            oldLicense = selectedState?.licenseList.filter("licenseType == %@", licenseType).first
        case "National":
            oldLicense = realm.objects(LicenseRepository.self).first?.nationalLicenseList.filter("licenseType == %@", licenseType).first
        default:
            print("Error loading old information")
        }
        
        licenseTextField.text = oldLicense?.licenseNumber
        issueDatePicker.date = oldLicense?.issueDate ?? Date()
        expirationDatePicker.date = oldLicense?.expirationDate ?? Date()
        alarmLabel.text = oldLicense?.alarmText
        licenseToPass = oldLicense
    }
    
    
    //MARK: - Set notification reminder
    
    func setNotification(days: Int) -> Void {
        let idString =  displayType + " " + licenseType + " " + (selectedState?.name ?? "")
        if days == 0 {
            manager.deleteNotification(id: idString)
            return
        } else {
            //Figure out notification date
            let expirationDate = expirationDatePicker.date
            var dateComponent = DateComponents()
            dateComponent.day = days * -1
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: expirationDate)
            print(idString)
            if let reminderDate = futureDate {
                manager.addNotification(title: "\(selectedState?.name ?? "") \(licenseType) License will expire soon.", dateTime: manager.currentDateComponents(reminderDate: reminderDate), id : idString)
            }
            manager.schedule()
        }
    }
    
    
    func displaySaveBanner(){
        
        savedLabel.isHidden = false
        UIView.animate(withDuration: 3, animations: { () -> Void in
            self.savedLabel.alpha = 0
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.savedLabel.isHidden = true
            self.savedLabel.alpha = 1
        }
    }
}

extension LicenseViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
