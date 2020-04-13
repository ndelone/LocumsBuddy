//
//  StateLicense.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//

import Foundation
import RealmSwift

class StateLicense : Object {
    let licenseList = List<License>()
    var parentCategory = LinkingObjects(fromType: LicenseRepository.self, property: "stateLicenseList")
}
