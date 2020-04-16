//
//  CredentialManagerViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/15/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit

class CredentialManagerViewController: UIViewController {

    let credentialTableManager = CredentialManagerTableViewController()
    @IBAction func employerButtonPressed(_ sender: UIButton) {
        self.navigationController?.pushViewController(credentialTableManager, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
