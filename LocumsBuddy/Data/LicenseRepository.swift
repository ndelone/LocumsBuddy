//
//  LicenseRepository.swift
//  LocumsBuddy2
//
//  Created by ND on 4/7/20.
//  Copyright © 2020 ND. All rights reserved.
//
import RealmSwift
import Foundation
class LicenseRepository : Object {
    let stateChoiceList = List<State>()
    let stateMedicalLicenseList = List<License>()
    let nationalLicenseList = List<License>()
    let employerList = List<Employer>()
    let healthList = List<HealthDocument>()
}
