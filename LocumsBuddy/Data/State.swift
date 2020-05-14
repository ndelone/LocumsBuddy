//
//  State.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//


import Foundation
import RealmSwift

class State : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var shouldAppearInPicker : Bool = true
    @objc dynamic var medicalLicense : License?
    @objc dynamic var deaLicense : License?
    
    let licenseList = List<License>()
     var parentCategory = LinkingObjects(fromType: LicenseRepository.self, property: "stateChoiceList")
}
