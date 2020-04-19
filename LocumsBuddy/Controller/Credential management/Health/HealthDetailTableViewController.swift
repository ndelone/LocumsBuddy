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
    var selectedDocument : HealthDocument?
    @IBOutlet weak var imageView: UIImageView!
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
            }
        } catch {
            print("Error saving health document")
        }
    }
    
    func loadDocument(){
        expirationDatePicker.date = selectedDocument?.expirationDate ?? Date()
        commentTextField.text = selectedDocument?.comment
    }
    
    
}
