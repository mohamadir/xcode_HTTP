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
import SwiftEventBus
import SwiftHTTP
import TTGSnackbar

class Counters: Codable{
    var total_unread_messages: Int?
    var total_unread_notifications: Int?
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    
    fileprivate func setRemoteNotfactionSettings(_ application: UIApplication) {
        print("Im here in notfaction fire base function")
        if #available(iOS 10.0, *){
            //notificationContent.sound = UNNotificationSound(named: "out.mp3")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
                
                if err != nil {
                    print("Firebase Error: \(String(describing: err))")
                }else {
                    print("Successful Authorization")
                    
                    UNUserNotificationCenter.current().delegate = self
                    
                    DispatchQueue.main.async {
                        Messaging.messaging().delegate = self
                        //UNNotificationSound.sound = UNNotificationSound(named: "out.caf")
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
        setUpSocket()
       
        application.registerForRemoteNotifications()
        
      
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        UNUserNotificationCenter.current().delegate = self
        checkCurrentUser()
       
        
        
        FirebaseApp.configure()
        print()
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)

        
        setRemoteNotfactionSettings(application)
        
       // UIApplication.shared.unregisterForRemoteNotifications()
        
        ConnectToFcm()
        
        SwiftEventBus.onMainThread(self, name: "registerRemote") { result in
            self.setRemoteNotfactionSettings(application)
        }
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
           // MyVriables.currentMember = Member(email: email, phone: phone, id: id)
            getNotificationsCounters()
        }
    }
    
    
    func ConnectToFcm(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("FIREBASETOPIC: didRegisterForRemoteNotificationsWithDeviceToken")
        Messaging.messaging().apnsToken = deviceToken
        let currentTopic: String = MyVriables.CurrentTopic
        if MyVriables.TopicSubscribe {
            if currentTopic != "" {
                print("FIREBASETOPIC: subscribe  \(currentTopic)")

                Messaging.messaging().subscribe(toTopic: "/topics/\(currentTopic)")

            }
        }
        if !MyVriables.TopicSubscribe {
            print("FIREBASETOPIC: un subscribe \(currentTopic)")

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
        print("App delegt socket")
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let isLogged = defaults.bool(forKey: "isLogged")
       // if isLogged == true
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        print("chat api: "+ApiRouts.ChatServer)
        socket = manager.defaultSocket
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "member-ֿ\(id)")
            
        }
        print("member-\(id):member-channel")
        
        self.socket!.on("member-\(id):member-channel") {data, ack in
            
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
        print("recieve in MessagingRemoteMessage \(remoteMessage.appData["total_unread_messages"])")
        print("recieve in MessagingRemoteMessage \(remoteMessage.appData["click_action"])")
        if remoteMessage.appData["click_action"] != nil
        {
            if "\((remoteMessage.appData["click_action"])!)" == "DELETE_FROM_GROUP"
            {
                print("Im here is equal")
                SwiftEventBus.post("refreshGroupChangeRole")
                if Messaging.messaging().fcmToken != nil {
                    MyVriables.TopicSubscribe = true
                    MyVriables.CurrentTopic = "IOS-Group-\(String(describing: (remoteMessage.appData["group_id"])!))"
                    Messaging.messaging().unsubscribe(fromTopic: "/topics/IOS-GROUP-\(String(describing: (remoteMessage.appData["group_id"])!))")
                }
            }
        }
        else
        {

        UIApplication.shared.applicationIconBadgeNumber += 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Snapgroup.Snap2"), object: nil)
        
        timedNotifications(inSeconds: 1) { (success) in
            if success {
                print("Successfully Notified")
            }
        }
        print("New budges \(UIApplication.shared.applicationIconBadgeNumber)")
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
    
    func getNotificationsCounters(){
        HTTP.GET(ApiRouts.Web + "/api/members/\((MyVriables.currentMember?.id!)!)/unread"){response in
            let data = response.data
            do {
                if response.error != nil {
                    return
                }
                let  counters = try JSONDecoder().decode(Counters.self, from: data)
                print(response.description)
                DispatchQueue.main.sync {
                    print("TOTALOSH: \(counters.total_unread_notifications!)")
                    print("TOTALOSH: \(counters.total_unread_messages!)")
                    self.setToUserDefaults(value: counters.total_unread_notifications!, key: "inbox_counter")
                    self.setToUserDefaults(value: counters.total_unread_messages!, key: "chat_counter")
                    SwiftEventBus.post("counters")
                    
                }
            }catch let error {
                print(error)
            }
        }
    }
    
    // new methods for remote message recevation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      //  print("recieve in UNNotificationResponse \(notification.description)")
        print("recieve in UNUserNotificationCenter")

       UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("recieve in UIBackgroundFetchResult \(userInfo)")
        if userInfo["total_unread_messages"] != nil {
            print("CHAT-COUNTER IN RECEIVE REMOTE ")
            self.setToUserDefaults(value: userInfo["total_unread_messages"]! , key: "chat_counter")
            SwiftEventBus.post("counters")
        }
        if userInfo["total_unread_notifications"] != nil {
            print("INBOX-COUNTER IN RECEIVE REMOTE ")
            self.setToUserDefaults(value: userInfo["total_unread_notifications"]! , key: "inbox_counter")
            SwiftEventBus.post("counters")
        }
        if userInfo["click_action"] != nil
        {
            if "\((userInfo["click_action"])!)" == "DELETE_FROM_GROUP"
            {
                print("Im here is equal")
                MyVriables.shouldRefresh = true
                SwiftEventBus.post("refreshData")
                if Messaging.messaging().fcmToken != nil {
                    MyVriables.TopicSubscribe = true
                    MyVriables.CurrentTopic = "IOS-Group-\(String(describing: (userInfo["group_id"])!))"
                    Messaging.messaging().unsubscribe(fromTopic: "/topics/IOS-GROUP-\(String(describing: (userInfo["group_id"])!))")
                
                    if let navigationController = self.window?.rootViewController as? UINavigationController {
                        print("[ABCController] is visible before")
                        let snackbar = TTGSnackbar(message: "You've been removed from \((userInfo["group_name"])!). Contact the group leader for details.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                        navigationController.popToRootViewController(animated: true)
                        print("[ABCController] is visible after")
                    }
                }
            }
            else
            {
                if "\(userInfo["click_action"]!)" == "LOCATION-NOTIFICATION"
                {
                    setMemberLocaion()
                }
            }
        }
        else {
        UIApplication.shared.applicationIconBadgeNumber += 1
        }
//        timedNotifications(inSeconds: 1) { (success) in
//            if success {
//                print("Successfully Notified")
//            }
//        }
    }
    
    func setToUserDefaults(value: Any?, key: String){
        if value != nil {
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
        }
        else{
            let defaults = UserDefaults.standard
            defaults.set("no value", forKey: key)
        }
        
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("recieve in UNNotificationResponse \(response.notification.description)")
  UIApplication.shared.applicationIconBadgeNumber = 0
//        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "Chat") as! ChatViewController
//        self.window?.rootViewController = homePage
//        completionHandler()
        
    }
    
    public func setMainRoot(){
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.window?.rootViewController = homePage
    }
    func setMemberLocaion() {
        var currentLocation: CLLocation!
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            currentLocation = locManager.location
            print("App delgete Location lat is \(currentLocation.coordinate.longitude) and location long is \(currentLocation.coordinate.latitude)")
            let defaults = UserDefaults.standard
            let id = defaults.integer(forKey: "member_id")
            HTTP.POST(ApiRouts.Web+"/api/members/locations/member/\(id)", parameters: ["lat": currentLocation.coordinate.latitude, "lon": currentLocation.coordinate.longitude]) { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                print("Response app delgete is \(response.description)")
            }
            
        }
        
    }
}


