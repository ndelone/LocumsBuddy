//
//  LocalNotificationManager.swift
//  LocumsBuddy2
//
//  Created by ND on 4/6/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UserNotifications

struct Notification {
    var id: String
    var title: String
    var dateTime: DateComponents
}

class LocalNotificationManager {
    var notifications = [Notification]()
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    
    func clearNotificationArray() {
        notifications.removeAll(keepingCapacity: false)
    }
    
    func listScheduledNotifications()
    {
        //print("entering list schedule: \(notifications)")
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
           }
        }
    }
    
    func schedule() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    
    func addNotification(title: String, dateTime: DateComponents, id : String) -> Void {
        notifications = [(Notification(id: id, title: title, dateTime: dateTime))]
    }
    
    func makeHealthIDString(selectedHealth: HealthDocument?) -> String{
        guard let name = selectedHealth?.name else {return ""}
        let healthString = "Health-\(name)"
        return healthString
    }
    
    func makeLicenseIDString(selectedLicense: License?) -> String {
        let licenseName = selectedLicense?.name
        let licenseType = selectedLicense?.licenseType
        let stateName = selectedLicense?.parentCategory.first?.name
        let idString = "\(licenseType!)-\(licenseName!)-\(stateName!)"
        
        return idString
    }
    
    func scheduleNotifications() -> Void {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: false)
           //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) Test trigger 5 seconds
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
    }
    
    func deleteNotification(id : String) {
        print("Attempting to delete notification with ID: \(id)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Deletion succesfully")
        
    }
    
    func currentDateComponents(reminderDate: Date)->DateComponents{
        let date = reminderDate
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//        let second = calendar.component(.second, from: date)
        let dateTime = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: 12)
        return dateTime
    }
    
    
}
