//
//  Employer.swift
//  LocumsBuddy
//
//  Created by ND on 4/16/20.
//  Copyright © 2020 ND. All rights reserved.
//

import Foundation
import RealmSwift

class Employer : Object {
    @objc dynamic var name : String?
    @objc dynamic var startDate : Date?
    @objc dynamic var endDate : Date?
    @objc dynamic var position : String = ""
    @objc dynamic var departmentChair : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var phone : String = ""
    @objc dynamic var comment : String = ""
    
    var parentCategory = LinkingObjects(fromType: LicenseRepository.self, property: "employerList")
}
