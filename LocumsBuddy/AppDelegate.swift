//
//  AppDelegate.swift
//  LocumsBuddy2
//
//  Created by ND on 4/6/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //MARK: - PDF Opening Document
    
    let notificationManager = LocalNotificationManager()
     let delegate = self
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
             print("Hi")
         //Load URL into the app.
         self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavigationViewController")
            shouldPushCV = true
            appDelegateURL = url

        self.window?.rootViewController = initialViewController
//        
            self.window?.makeKeyAndVisible()
         print("Opening application document url is \(url)")
         //initialViewController.loadDocument(documentURL: url)
         return true
     }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("I'm an app delegate")
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        do{
            _ = try Realm()
        } catch {
            print("Error in realming")
        }
        
        UNUserNotificationCenter.current().delegate = self
        notificationManager.requestPermission()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
    -> Void) {
    completionHandler([.alert, .badge, .sound])
}
}
