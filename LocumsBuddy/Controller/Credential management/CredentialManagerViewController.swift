//
//  CredentialManagerViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/15/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift

class CredentialManagerViewController: UIViewController {
    @IBOutlet weak var healthOutlet: UIButton!
    @IBOutlet weak var employerOutlet: UIButton!
    @IBOutlet weak var cmeOutlet: UIButton!
    @IBAction func employerButtonPressed(_ sender: UIButton) {
    
    }
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadows(healthOutlet)
        addShadows(employerOutlet)
        addShadows(cmeOutlet)
        // Do any additional setup after loading the view.
    }
    

    func addShadows(_ button : UIButton){
         button.layer.shadowColor = UIColor.black.cgColor
         button.layer.shadowOffset = CGSize(width: 5, height: 5)
         button.layer.shadowRadius = 5
         button.layer.shadowOpacity = 1.0
     }
}
