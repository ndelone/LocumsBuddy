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
    var selectedDocument : HealthDocument?
    let alertDict = [ 0 : "None", 1: "One day before", 7: "One week before", 14: "Two weeks before", 30: "One month before"]
    var alertTime : Int?{
        didSet {
            print("This value was set for \(alertTime)")
            reminderLabel.text = alertDict[alertTime ?? 0]
            setNotification()
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
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
            self.alertTime = 0
        }
        
        let oneDay = UIAlertAction(title: "One day", style: .default) { (oneDay) in
            self.alertTime = 1
        }
        
        let oneWeek = UIAlertAction(title: "One week", style: .default) { (oneWeek) in
            self.alertTime = 7
        }
        
        let twoWeeks = UIAlertAction(title: "Two weeks", style: .default) { (twoWeeks) in
            self.alertTime = 14
        }
        
        let oneMonth = UIAlertAction(title: "One month", style: .default) { (oneMonth) in
            self.alertTime = 30
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
    
    func setNotification(){
        let expirationDate = expirationDatePicker.date
        var dateComponent = DateComponents()
        dateComponent.day = alertTime! * -1
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: expirationDate) else {return}
        let notificationID = notificationManager.makeHealthIDString(selectedHealth: selectedDocument)
        notificationManager.addNotification(title: "\(selectedDocument?.name) will expire on ", dateTime: notificationManager.currentDateComponents(reminderDate: futureDate), id: notificationID)
        notificationManager.schedule()
    }
}
