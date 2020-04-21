//
//  EmployerDetailTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/16/20.
//  Copyright © 2020 ND. All rights reserved.
//

import RealmSwift
import UIKit

class EmployerDetailTableViewController: UITableViewController {

    let realm = try! Realm()
    var selectedEmployer : Employer?
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var chairTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBAction func startDateChanged(_ sender: UIDatePicker) {
        endDatePicker.minimumDate = sender.date
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEmployer()
        
        //Draw a border on textview
        addressTextView!.layer.borderWidth = 1
        addressTextView!.layer.borderColor = UIColor.lightGray.cgColor
        addressTextView!.layer.cornerRadius = 6
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveEmployer()
    }
    
    
    //MARK: - Data methods

    func saveEmployer(){
        do {
            try realm.write{
                selectedEmployer?.address = addressTextView.text
                selectedEmployer?.departmentChair = chairTextField.text!
                selectedEmployer?.endDate = endDatePicker.date
                selectedEmployer?.phone = phoneTextField.text!
                selectedEmployer?.position = positionTextField.text!
                selectedEmployer?.startDate = startDatePicker.date
                selectedEmployer?.comment = commentsTextField.text!
            }
        } catch {
            print("Error saving employer data to realm")
        }
    }
    
    func loadEmployer(){
        addressTextView.text = selectedEmployer?.address
        chairTextField.text = selectedEmployer?.departmentChair
        endDatePicker.date = selectedEmployer?.endDate ?? Date()
        phoneTextField.text = selectedEmployer?.phone
        positionTextField.text = selectedEmployer?.position
        startDatePicker.date = selectedEmployer?.startDate ?? Date()
        commentsTextField.text = selectedEmployer?.comment
    }
}

extension EmployerDetailTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
