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
        FirebaseApp.configure()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
            
            if err != nil {
                print("Firebase Error: \(err)")
            }else {
                print("Successful Authorization")
                
                UNUserNotificationCenter.current().delegate = self
                
                DispatchQueue.main.async {
                    Messaging.messaging().delegate = self
                    UIApplication.shared.registerForRemoteNotifications()
                    Messaging.messaging().subscribe(toTopic: "/topics/a123456")

                }
                
                
            }
            
            
            }
            
        }else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            Messaging.messaging().delegate = self
            UIApplication.shared.registerForRemoteNotifications()
            print("Successful Authorization")

            Messaging.messaging().subscribe(toTopic: "/topics/a123456")
            
        }
        
        
        
        
        
        
        application.registerForRemoteNotifications()
        
        ConnectToFcm()
        
        
        // AIzaSyDv9JFsM6elRHpluMelqZZvLBoRBL6JK6I
        // AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg
        GMSServices.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
        GMSPlacesClient.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
        
        return true
    }
    
    
    func ConnectToFcm(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
        }
        
        
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().subscribe(toTopic: "/topics/a123457")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        ConnectToFcm()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        ConnectToFcm()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = true
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        ConnectToFcm()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
   
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("notification remoteMessage->  " + remoteMessage.appData.description)
        
        // \((remoteMessage.appData["message"]!))"
    
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)
        timedNotifications(inSeconds: 1) { (success) in
            if success {
                print("Successfully Notified")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Notificationnnn didReceiveRemoteNotification")
        
    }
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("notification remoteMessage 2 ")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)")
        
        
    }
    func timedNotifications(inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        
//        if #available(iOS 10.0, *) {
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
//        } else {
//            // Fallback on earlier versions
//        }
//
//        let content = UNMutableNotificationContent()
//
//        content.title = "Breaking News"
//        content.subtitle = "Yo whats up i am subtitle"
//        content.body = "idbnqwkdnqwoidoqw;edn;owqdno;wqndo;qwndowqndoqwdn qwdkj"
//
//        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if error != nil {
//                completion(false)
//            }else {
//                completion(true)
//            }
//        }
    }
    
}


