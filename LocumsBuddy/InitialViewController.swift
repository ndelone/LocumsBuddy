//
//  ViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/6/20.
//  Copyright © 2020 ND. All rights reserved.
//
public var appDelegateURL: URL?
public var shouldPushCV = false
import UIKit
import RealmSwift

class ViewController: UIViewController {
    let notificationManager = LocalNotificationManager()
    
    @IBOutlet weak var documentListButtonOutlet: UIButton!
    @IBOutlet weak var cvButtonOutlet: UIButton!
    @IBOutlet weak var expirationListButtonOutlet: UIButton!
    @IBOutlet weak var nationalButtonOutlet: UIButton!
    @IBOutlet weak var stateButtonOutlet: UIButton!
    @IBAction func listNotificationsButtonPressed(_ sender: UIButton) {
        notificationManager.listScheduledNotifications()
    }
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(shouldPushCV)
        if (shouldPushCV){
            print("I need to push CV")
            performSegue(withIdentifier: "cvSegue", sender: self)
        }
            addShadows(nationalButtonOutlet)
            addShadows(cvButtonOutlet)
        addShadows(expirationListButtonOutlet)
        addShadows(stateButtonOutlet)
        addShadows(documentListButtonOutlet)
        initializingFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func initializingFunction(){
        if (realm.objects(LicenseRepository.self).count < 1) {
            print("No License Repository has been established, setting one up now.")
            let initialStateList = ["Alaska","Alabama","Arkansas","American Samoa","Arizona","California","Colorado","Connecticut","District of Columbia","Delaware","Florida","Georgia","Guam","Hawaii","Iowa","Idaho","Illinois","Indiana","Kansas","Kentucky","Louisiana","Massachusetts","Maryland","Maine","Michigan","Minnesota","Missouri","Mississippi","Montana","North Carolina","North Dakota","Nebraska","New Hampshire","New Jersey","New Mexico","Nevada","New York","Ohio","Oklahoma","Oregon","Pennsylvania","Puerto Rico","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Virginia","Virgin Islands","Vermont","Washington","Wisconsin","West Virginia","Wyoming"]
            let nationalLicenses = ["NPI", "ACLS","PALS","ATLS"]
            do {
                try realm.write {
                    //State License Fulfillment
                    let newLicenseArray = LicenseRepository()
                    for state in initialStateList {
                        let newState = State()
                        newState.name = state
                        let savingPath =  "State Licenses/\(state)"
                        //Adding in default DEA/Medical licenses
                        let newMedicalLicense = License()
                        newMedicalLicense.licenseType = "Medical"
                        newMedicalLicense.savingPath = savingPath
                        newState.licenseList.append(newMedicalLicense)
                        
                        
                        let newDEALicense = License()
                        newDEALicense.licenseType = "DEA"
                        newDEALicense.savingPath = savingPath
                        newState.licenseList.append(newDEALicense)
                        
                        
                        newLicenseArray.stateChoiceList.append(newState)
                    }
                    //Create base directories
                    createNewDirectory(stateName: "State Licenses", parentDirectoryString: "")
                    createNewDirectory(stateName: "National Licenses", parentDirectoryString: "")
                    createNewDirectory(stateName:"Health",parentDirectoryString: "")
                    
                    //Nationan License Fulfillment
                    for license in nationalLicenses {
                        let newNationalLicense = License()
                        let savingPath = "National Licenses/\(license)"
                        newNationalLicense.licenseType = license
                        newNationalLicense.savingPath = savingPath
                        newLicenseArray.nationalLicenseList.append(newNationalLicense)
                        createNewDirectory(stateName: "\(license)", parentDirectoryString: "National Licenses/")
                    }
                    
                    realm.add(newLicenseArray)
                    print("New License Array initialized")
                }
            } catch {
                print("Error initializing categories")
            }
        } else {
            print("A license repository exists already")
        }
    }
    
    func createNewDirectory( stateName: String, parentDirectoryString : String){
        
        //        let fileManager = FileManager.default
        let documentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesPath = documentsURL.appendingPathComponent(parentDirectoryString + stateName)
        do
        {
            try FileManager.default.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            print("imagesPath is \(imagesPath)")
            print("documentsURL is \(documentsURL)")
            //imagePath = imagesPath
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }

    
    func addShadows(_ button : UIButton){
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 5, height: 5)
            button.layer.shadowRadius = 5
            button.layer.shadowOpacity = 1.0
    }
    
}

