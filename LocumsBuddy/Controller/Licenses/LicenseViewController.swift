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
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var issueDatePicker: UIDatePicker!
    @IBOutlet weak var renewalTableViewCell: UITableViewCell!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    @IBAction func issueDateChanged(_ sender: UIDatePicker) {
        expirationDatePicker.minimumDate = sender.date
    }
    @IBAction func expirationDateChanged(_ sender: UIDatePicker) {
        issueDatePicker.maximumDate = sender.date
        inputValidation(alertTimeDays: 0)
    }
    @IBOutlet weak var licenseTextField: UITextField!
    
    let manager = LocalNotificationManager()
    var alertTime: Int = 0 {
        didSet{
            alarmLabel.text = alertDict[alertTime]
        }
    }
    let alertDict = [ 0 : "None", 1: "One day before", 7: "One week before", 14: "Two weeks before", 30: "One month before"]
    let realm = try! Realm()
    var selectedLicense : License?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licenseTextField.delegate = self
        loadInformation()
        
        setImageInformation()
    }
    
    
    func setImageInformation(){
        super.imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(selectedLicense!.savingPath)
        super.imageName = "\(selectedLicense!.name).jpeg"
        super.loadImageView = imageView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You pressed row \(indexPath.row)")
        if indexPath.row == 3 {
            reminderAlert()
            print(alertTime)
        }
        if indexPath.row == 4 {
            super.saveButtonPressedDone()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveLicense()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "renewalSegue":
            let destinationVC = segue.destination as! RenewLicenseTableViewController
            destinationVC.selectedLicense = selectedLicense
        default:
            let destinationVC = segue.destination as! RenewLicenseTableViewController
            destinationVC.selectedLicense = selectedLicense
        }
    }
    
    //MARK: - Validate licenses input
    
    func validationAlert(alarmText : String){
        let alert = UIAlertController(title: alarmText, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func inputValidation(alertTimeDays: Int) {
        //Check issue date is before today
        if alertTimeDays == 0 {
            alertTime = 0
            setNotification(days: alertTimeDays)
        } else {
            var dateComponent = DateComponents()
            dateComponent.day = alertTimeDays * -1
            let reminderDate = Calendar.current.date(byAdding: dateComponent, to: Calendar.current.startOfDay(for: expirationDatePicker.date))
            let today = Calendar.current.startOfDay(for: Date())
            //Ensure alarm date is at least 2 days from current date
            guard let diffInDays = Calendar.current.dateComponents([.day], from: today, to: reminderDate!).day else {return}
            print(diffInDays)
            if diffInDays >= 2 {
                print("Passed validation")
                alertTime = alertTimeDays
                setNotification(days: alertTimeDays)
            } else {
                validationAlert(alarmText: "Reminder needs to be at least 2 days from today.")
            }
        }
    }
    
    func saveLicense(){
        
        let newLicense = License()
        newLicense.licenseNumber = licenseTextField.text
        newLicense.issueDate = issueDatePicker.date
        newLicense.expirationDate = expirationDatePicker.date
        newLicense.licenseType = selectedLicense!.licenseType
        newLicense.showReminder = true
        newLicense.alarmText = alarmLabel.text ?? "None"
        newLicense.name = selectedLicense!.name
        newLicense.savingPath = selectedLicense!.savingPath
        newLicense.renewalCMEYears = selectedLicense!.renewalCMEYears
        newLicense.renewalURLString = selectedLicense!.renewalURLString
        newLicense.renewalFee = selectedLicense!.renewalFee
        newLicense.renewalCMEs = selectedLicense!.renewalCMEs
        
        do {
            try realm.write{
                selectedLicense?.parentCategory.first?.licenseList.append(newLicense)
                realm.delete(selectedLicense!)
                selectedLicense = newLicense
            }
        } catch {
            print("Error in writing new state license")
        }
    }
    
    //MARK: - Loading initial information
    
    func loadInformation(){
        licenseTextField.text = selectedLicense?.licenseNumber
        issueDatePicker.date = selectedLicense?.issueDate ?? Date()
        expirationDatePicker.date = selectedLicense?.expirationDate ?? Date()
        alarmLabel.text = selectedLicense?.alarmText
        self.title = "\(selectedLicense!.name) license"
        renewalTableViewCell.isHidden = !(selectedLicense?.name == "Medical")
        renewalTableViewCell.isUserInteractionEnabled = (selectedLicense?.name == "Medical")
    }
    
    
    //MARK: - Set notification reminder
    
    func setNotification(days: Int) -> Void {
        let idString =  manager.makeLicenseIDString(selectedLicense: selectedLicense)
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
            if let reminderDate = futureDate, let licenseName = selectedLicense?.name {
                manager.addNotification(title: "\(selectedLicense?.parentCategory.first?.name ?? "") \(licenseName) License will expire soon.", dateTime: manager.currentDateComponents(reminderDate: reminderDate), id : idString)
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
    //MARK: - Alert stuff
    
    func reminderAlert(){
        let alert = UIAlertController(title: "How long before expiration would you like to be reminded?", message: "", preferredStyle: .actionSheet)
        
        
        let none = UIAlertAction(title: "None", style: .default) { (none) in
            self.inputValidation(alertTimeDays: 0)
        }
        
        let oneDay = UIAlertAction(title: "One day", style: .default) { (oneDay) in
            self.inputValidation(alertTimeDays: 1)
        }
        
        let oneWeek = UIAlertAction(title: "One week", style: .default) { (oneWeek) in
            self.inputValidation(alertTimeDays: 7)
        }
        
        let twoWeeks = UIAlertAction(title: "Two weeks", style: .default) { (twoWeeks) in
            self.inputValidation(alertTimeDays: 14)
        }
        
        let oneMonth = UIAlertAction(title: "One month", style: .default) { (oneMonth) in
            self.inputValidation(alertTimeDays: 30)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) -> Void in
            
        })
        
        alert.addAction(none)
        alert.addAction(oneDay)
        alert.addAction(oneWeek)
        alert.addAction(twoWeeks)
        alert.addAction(oneMonth)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
        
    }
}

extension LicenseViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
