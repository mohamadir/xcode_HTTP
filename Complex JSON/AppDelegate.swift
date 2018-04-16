//
//  AppDelegate.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import GoogleMaps
import GooglePlaces
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
            
            if err != nil {
                print("Firebase Error: \(err)")
            }else {
                print("Successful Authorization")
                
                UNUserNotificationCenter.current().delegate = self

                Messaging.messaging().delegate = self
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            
                Messaging.messaging().subscribe(toTopic: "/topics/CHAT-77")
            }
            
            
        }
        FirebaseApp.configure()

        
        // AIzaSyDv9JFsM6elRHpluMelqZZvLBoRBL6JK6I
        GMSServices.provideAPIKey("AIzaSyDv9JFsM6elRHpluMelqZZvLBoRBL6JK6I")
        GMSPlacesClient.provideAPIKey("AIzaSyDv9JFsM6elRHpluMelqZZvLBoRBL6JK6I")
        
        return true
    }
    
    func ConnectToFcm(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
        }
        
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        
        ConnectToFcm()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ConnectToFcm()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        print("Notificationnnn")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)
    }
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler(.alert)
//    }
//}

