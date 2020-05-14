//
//  License.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//

import Foundation
import RealmSwift

class License : Object {
    @objc dynamic var licenseNumber : String? = ""
    @objc dynamic var licenseType : String = ""
    @objc dynamic var issueDate: Date?
    @objc dynamic var expirationDate: Date?
    @objc dynamic var showReminder: Bool = true
    @objc dynamic var alarmText = "None"
    @objc dynamic var savingPath = ""
    @objc dynamic var name = ""
    
    //License renewal data
    @objc dynamic var renewalCMEs = 0
    @objc dynamic var renewalFee  = 0.0
    @objc dynamic var renewalCMEYears : Int = 0
    @objc dynamic var renewalURLString : String = ""
    
    var parentCategory = LinkingObjects(fromType: State.self, property: "licenseList")
}
