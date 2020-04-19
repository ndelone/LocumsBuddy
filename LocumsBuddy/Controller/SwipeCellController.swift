//
//  SwipeCell.swift
//  LocumsBuddy
//
//  Created by ND on 4/16/20.
//  Copyright © 2020 ND. All rights reserved.
//


import SwipeCellKit
import UIKit
import RealmSwift

class SwipeCellController : UITableViewController, SwipeTableViewCellDelegate, UITextFieldDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.updateModel(at: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructiveAfterFill
        
        return options
    }
    
    func updateModel(at indexPath : IndexPath){
        //update datamodel
    }
    
    //MARK: - Add an item alert
    weak var actionToEnable : UIAlertAction?

    func showAlert(title: String, message: String, placeHolder: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let placeholderStr =  placeHolder

        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = placeholderStr
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })

        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) -> Void in

        })

        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            let textfield = alert.textFields!.first!
            self.addNewItem(textfield.text!)
//            self.addNewCME(textfield.text!)
//            Do what you want with the textfield!
        })

        alert.addAction(cancel)
        alert.addAction(action)

        self.actionToEnable = action
        action.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }

    @objc func textChanged(_ sender:UITextField) {
//        if sender.text! != "" {
//            print("This many objects share same name: \(cmeList?.filter("name ==[cd] %@", sender.text!).count)")
//            if ((cmeList?.filter("name ==[cd] %@", sender.text!).count) ?? 0 == 0) {
//                self.actionToEnable?.isEnabled = true
//            } else {
//                self.actionToEnable?.isEnabled = false
//            }
//        } else {
//            self.actionToEnable?.isEnabled = true
//        }
    }

    func addNewItem(_ name: String){
        //Add new item
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
//        print("Hey")
//    }
}

