//
//  HealthDetailTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/17/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift

class HealthDetailTableViewController: PhotoViewClass {
    
    let realm = try! Realm()
    let notificationManager = LocalNotificationManager()
    var selectedDocument : HealthDocument? {
        didSet{
            self.title = selectedDocument?.name
        }
    }
    let alertDict = [ 0 : "None", 1: "One day before", 7: "One week before", 14: "Two weeks before", 30: "One month before"]
    var alertTime : Int = 0{
        didSet {
            print("This value was set for \(alertTime)")
            reminderLabel.text = alertDict[alertTime]
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    @IBAction func expirationPickerDidChange(_ sender: Any) {
        inputValidation(alertTimeDays: 0)
    }
    override func viewDidLoad() {
        super.imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Health")
        super.imageName = "\(self.title!).jpeg"
        super.loadImageView = imageView
        loadDocument()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected row \(indexPath.row)")
        if indexPath.row == 3 {
            super.saveButtonPressedDone()
        }
        if indexPath.row == 2 {
            reminderAlert()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveDocument()
    }
    
    
    func saveDocument(){
        do {
            try realm.write{
                selectedDocument?.comment = commentTextField.text!
                selectedDocument?.expirationDate = expirationDatePicker.date
                selectedDocument?.notificationReminder = reminderLabel.text
            }
        } catch {
            print("Error saving health document")
        }
    }
    
    func loadDocument(){
        expirationDatePicker.date = selectedDocument?.expirationDate ?? Date()
        commentTextField.text = selectedDocument?.comment
        reminderLabel.text = selectedDocument?.notificationReminder ?? "None"
    }
    
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
    
    func setNotification(alertDays: Int){
        let idString = notificationManager.makeHealthIDString(selectedHealth: selectedDocument)
        if alertDays == 0 {
            notificationManager.deleteNotification(id: idString)
            return
        } 
        let expirationDate = expirationDatePicker.date
        var dateComponent = DateComponents()
        dateComponent.day = alertDays * -1
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: expirationDate) else {return}
        notificationManager.addNotification(title: "\(selectedDocument!.name) will expire soon.", dateTime: notificationManager.currentDateComponents(reminderDate: futureDate), id: idString)
        notificationManager.schedule()
    }
    
    func inputValidation(alertTimeDays: Int) {
        //Check issue date is before today
        if alertTimeDays == 0 {
            alertTime = 0
            setNotification(alertDays: alertTimeDays)
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
                setNotification(alertDays: alertTimeDays)
            } else {
                validationAlert(alarmText: "Reminder needs to be at least 2 days from today.")
            }
        }
    }
    
    func validationAlert(alarmText : String){
        let alert = UIAlertController(title: alarmText, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
