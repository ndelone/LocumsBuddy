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

class SwipeCellController : UITableViewController, SwipeTableViewCellDelegate{
    
    
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
    
    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        print("Hey")
    }
}

