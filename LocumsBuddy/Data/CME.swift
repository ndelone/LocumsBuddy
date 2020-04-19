//
//  CME.swift
//  LocumsBuddy
//
//  Created by ND on 4/17/20.
//  Copyright © 2020 ND. All rights reserved.
//

import Foundation
import RealmSwift
class CME : Object {
    @objc dynamic var issueDate: Date?
    @objc dynamic var creditType : String = ""
    @objc dynamic var creditAmount : Int = 0
    @objc dynamic var comment = ""
    @objc dynamic var name = ""
    
    var parentCategory = LinkingObjects(fromType: LicenseRepository.self, property: "cmeList")
}
