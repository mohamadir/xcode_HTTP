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
import SocketIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        UNUserNotificationCenter.current().delegate = self
        checkCurrentUser()
       
        
        
        FirebaseApp.configure()
        print()
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)
        
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
                        application.registerForRemoteNotifications()
                        
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
        }
        
        
        
        
        
        
        application.registerForRemoteNotifications()
        
        ConnectToFcm()
        
        
        // AIzaSyDv9JFsM6elRHpluMelqZZvLBoRBL6JK6I
        // AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg
        GMSServices.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
        GMSPlacesClient.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
        
        return true
    }
    
    
    func checkCurrentUser(){
        print("hihihi")
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let first = defaults.string(forKey: "first_name")
        let last = defaults.string(forKey: "last_name")
        let email = defaults.string(forKey: "email")
        let phone = defaults.string(forKey: "phone")
        let profile_image = defaults.string(forKey: "profile_image")
        let gender = defaults.string(forKey: "gender")
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == true{
            MyVriables.currentMember = Member(email: email, phone: phone, id: id)
        }
    }
    
    
    func ConnectToFcm(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let currentTopic: String = MyVriables.CurrentTopic
        if MyVriables.TopicSubscribe {
            if currentTopic != "" {
                print("CURRENT-TOPIC \(currentTopic)")
                Messaging.messaging().subscribe(toTopic: "/topics/\(currentTopic)")
            }
        }
        if !MyVriables.TopicSubscribe {
            if currentTopic != "" {
                Messaging.messaging().unsubscribe(fromTopic: "/topics/\(currentTopic)") 
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        ConnectToFcm()
    }
    func setUpSocket(){
        print("----- ABED -----")
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        print("chat api: "+ApiRouts.ChatServer)
        socket = manager.defaultSocket
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "member-ֿ\((MyVriables.currentMember?.id!)!)")
            
        }
        print("member-\((MyVriables.currentMember?.id!)!):member-channel")
        
        self.socket!.on("member-\((MyVriables.currentMember?.id!)!):member-channel") {data, ack in
            
            print("got message from socket")
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                    print(messageClass)
                    print(messageClass["id"]!)
                }
            }
            
        }
        
        
        socket!.onAny { (socEvent) in
            
            if let status =  socEvent.items as? [SocketIOStatus] {
                if let first = status.first {
                    switch first {
                    case .connected:
                        print("Socket: connected")
                        break
                        
                    case .disconnected:
                        print("Socket: disconnected")
                        break
                    case .notConnected:
                        print("Socket: notConnected")
                        break
                    case .connecting:
                        print("Socket: connecting")
                        break
                    default :
                        print("NOTHING")
                        break
                    }
                }
            }
        }
        
        self.socketManager = manager
        self.socket!.connect()
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        ConnectToFcm()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = true
        ConnectToFcm()
        
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
        print("recieve in MessagingRemoteMessage")
        
        
        // \((remoteMessage.appData["message"]!))"
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)
        timedNotifications(inSeconds: 1) { (success) in
            if success {
                print("Successfully Notified")
            }
        }
    }
    
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("notification remoteMessage 2 ")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)")
    }
    func timedNotifications(inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        let content = UNMutableNotificationContent()
        
        content.title = "Breaking News"
        content.subtitle = "Yo whats up i am subtitle"
        content.body = "idbnqwkdnqwoidoqw;edn;owqdno;wqndo;qwndowqndoqwdn qwdkj"
        
        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                completion(false)
            }else {
                completion(true)
            }
        }
    }
    // new methods for remote message recevation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      //  print("recieve in UNNotificationResponse \(notification.description)")
        
       UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("recieve in UIBackgroundFetchResult \(application.applicationState)")
        
        UIApplication.shared.applicationIconBadgeNumber += 1
//        timedNotifications(inSeconds: 1) { (success) in
//            if success {
//                print("Successfully Notified")
//            }
//        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("recieve in UNNotificationResponse \(response.notification.description)")
       // UIApplication.shared.applicationIconBadgeNumber = 0
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "Chat") as! ChatViewController
        self.window?.rootViewController = homePage
        completionHandler()
        
    }
    
    public func setMainRoot(){
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.window?.rootViewController = homePage
    }
}


