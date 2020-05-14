//
//  CMEDetailsTableViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/17/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift

class CMEDetailsTableViewController: PhotoViewClass {
    
    let realm = try! Realm()
    @IBOutlet weak var issueDatePicker: UIDatePicker!
    @IBOutlet weak var creditTypePicker: UIPickerView!
    let creditTypeData = ["AMA PRA I", "AMA PRA II"]
    lazy var creditTypeDict = [creditTypeData[0]: 0, creditTypeData[1]: 1]
    @IBOutlet weak var creditAmountPicker: UIPickerView!
    let creditAmountPickerData = (1...30).map { $0 }
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var selectedCME : CME?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creditAmountPicker.delegate = self
        creditTypePicker.delegate = self
        loadData()
        
        imageSetUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData()
    }

    
    //MARK: - Setup

    func imageSetUp(){
        super.imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("CME")
        super.imageName = "\(self.title!).jpeg"
        super.loadImageView = imageView
    }

    //MARK: - Data methods

    func loadData(){
        issueDatePicker.date = selectedCME?.issueDate ?? Date()
        creditAmountPicker.selectRow(((selectedCME?.creditAmount ?? 1) - 1), inComponent: 0, animated: false)
        creditTypePicker.selectRow(creditTypeDict[selectedCME?.creditType ?? "AMA PRA I"] ?? 0, inComponent: 0, animated: false)
        print(creditTypeDict[selectedCME?.creditType ?? "AMA PRA I"])
        commentTextField.text = selectedCME?.comment
    }

    func saveData(){
        do {
            try realm.write{
                selectedCME?.issueDate = issueDatePicker.date
                selectedCME?.creditType = creditTypeData[creditTypePicker.selectedRow(inComponent: 0)]
                selectedCME?.creditAmount = (creditAmountPicker.selectedRow(inComponent: 0)+1)
                selectedCME?.comment = commentTextField.text!
            }
        } catch {
            print("Error saving CME")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            super.saveButtonPressedDone()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}




extension CMEDetailsTableViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    //MARK: - Pickerview
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         1
     }
     
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case creditTypePicker:
            return creditTypeData.count
        case creditAmountPicker:
            return creditAmountPickerData.count
        default:
            return 1
        }
     }
    
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Gets the title for each row in picker
        switch pickerView {
        case creditTypePicker:
            return creditTypeData[row]
        case creditAmountPicker:
            return String(creditAmountPickerData[row])
        default:
            return "Error"
        }
    }
    
}
