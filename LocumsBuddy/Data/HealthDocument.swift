//
//  PersonalHealthDocument.swift
//  LocumsBuddy
//
//  Created by ND on 4/17/20.
//  Copyright © 2020 ND. All rights reserved.
//

import Foundation
import RealmSwift

class HealthDocument : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var comment: String?
    @objc dynamic var expirationDate : Date?
    @objc dynamic var notificationReminder: String?
    @objc dynamic var showReminder : Bool = true

    var parentCategory = LinkingObjects(fromType: LicenseRepository.self, property: "healthList")
}
