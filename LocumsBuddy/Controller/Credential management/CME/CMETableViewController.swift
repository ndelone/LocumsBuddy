//
//  CMETableViewController.swift
//  
//
//  Created by ND on 4/17/20.
//

import UIKit
import RealmSwift

class CMETableViewController: SwipeCellController {
    
    let realm = try! Realm()
    var selectedCME : CME?
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        super.showAlert(title: "Add CME", message: "Enter a unique name", placeHolder: "i.e. AMA 2019")
//         generateAddAlert()
    }
    var cmeList : Results<CME>?
    let K = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCME()
    }
    
    
    //Table actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCME = cmeList?[indexPath.row]
        performSegue(withIdentifier: "cmeDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CMEDetailsTableViewController
        destinationVC.selectedCME = selectedCME
        destinationVC.title = selectedCME?.name
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(cmeList?.count ?? 1)
        return cmeList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = cmeList?[indexPath.row].name ?? "Nothing here yet. Hit (+) to get started"
        cell.textLabel?.textColor = K.textColor
        cell.textLabel?.font = K.textFont
        return cell
    }
    
    func formatDate(_ date : Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
        let formattedDateString = dateFormatterPrint.string(from: date)
        return formattedDateString
    }
    
    //MARK: - Add Button Pressed/Generate alert

    @objc override func textChanged(_ sender:UITextField) {
        if sender.text! != "" {
            if ((cmeList?.filter("name ==[cd] %@", sender.text!).count) ?? 0 == 0) {
                self.actionToEnable?.isEnabled = true
            } else {
                self.actionToEnable?.isEnabled = false
            }
        } else {
            self.actionToEnable?.isEnabled = true
        }
    }

    //MARK: - Data methods
    
    override func addNewItem(_ name: String) {
        do {
            try realm.write{
                let newCME = CME()
                newCME.name = name
                realm.objects(LicenseRepository.self).first?.cmeList.append(newCME)
            }
        } catch {
            print("Error adding CME")
        }
        tableView.reloadData()
    }
    
    func loadCME(){
        cmeList = realm.objects(CME.self)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete item in realm
        print("Deleting CME in realm")
        
        do {
            try realm.write {
                if let documentToDelete = cmeList?[indexPath.row] {
                    realm.delete(documentToDelete)
                }
            }
        } catch {
            print("error deleting cme")
        }
    }
    
}
