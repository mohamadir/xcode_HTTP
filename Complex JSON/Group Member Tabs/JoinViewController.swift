//
//  JoinViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/22/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import SkyFloatingLabelTextField
import Toast_Swift
import FirebaseMessaging
import SwiftEventBus
import TTGSnackbar
class JoinViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
   

 
    @IBOutlet weak var lastNameTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTextFeild: SkyFloatingLabelTextField!
    var gender: String = "Male"
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var phoneTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var observerView: UIView!
    @IBOutlet weak var memberView: UIView!
    let genderData: [String] = ["Male","Female","Other"]
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextFeild.title = "Phone Number"
        phoneTextFeild.placeholder = " phone Number"
        firstNameTextFeild.title = "First Name"
        firstNameTextFeild.placeholder = " First Name"
        lastNameTextFeild.title = "Last Name"
        lastNameTextFeild.placeholder = " Last Name"
        setFontType(phoneTextFeild)
         setFontType(firstNameTextFeild)
         setFontType(lastNameTextFeild)
//        if (MyVriables.currentMember?.id)! == -1 {
//            self.phoneTextFeild.isEnabled = false
//        }
//        else {
            self.phoneTextFeild.isEnabled = false
        //}
            SwiftEventBus.onMainThread(self, name: "refreshGroupRole") { result in
                self.getGroup()
            }
      
    }
    fileprivate func setFontType(_ tf: SkyFloatingLabelTextField) {
        tf.font = UIFont(name: "Arial", size: 16)
        tf.titleFont = UIFont(name: "Arial", size: 16)!
        tf.placeholderFont = UIFont(name: "Arial", size: 16)
    }
    func showToast(_ message: String,_ duration: Double){
        var style = ToastStyle()
        // this is just one of many style options
        style.messageColor = .white
        // present the toast with the new style
        self.view.makeToast(message, duration: duration, position: .bottom, style: style)
    }
    

    func getGroup(){
        print("Url is " + ApiRouts.Web + "/api/groups/\((MyVriables.currentInboxMessage?.group_id!)!)/details/\((MyVriables.currentMember?.id!)!)")
        HTTP.GET(ApiRouts.Web + "/api/groups/\((MyVriables.currentInboxMessage?.group_id!)!)/details/\((MyVriables.currentMember?.id!)!)"){response in
            if response.error != nil {
                return
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                MyVriables.currentGroup = group2.group
                DispatchQueue.main.sync {
                  
                    if MyVriables.currentGroup?.role != nil {
                        self.changeStatusTo(type: (MyVriables.currentGroup?.role!)!)
                    }
                      print("Role is \((MyVriables.currentGroup?.role!)!)")
                }
            }
            catch let error{
                print("getGroup : \(error)")
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("roleStatus" +  MyVriables.roleStatus)

        if MyVriables.roleStatus == "member" {
            observerView.isHidden = true
            memberView.isHidden = false
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
            self.tabBarController?.tabBar.items![1].title = "Joined"
            self.tabBarController?.tabBar.items![1].selectedImage =  UIImage(named: "joinedFooter")

            
        }
        else {
            observerView.isHidden = false
            memberView.isHidden = true
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
            self.tabBarController?.tabBar.items![1].title = "join"
            self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "join group")
            setObserverPage()
        }
    }
    func setObserverPage(){
        
        let defaults = UserDefaults.standard

        let id = defaults.integer(forKey: "member_id")
        let first = defaults.string(forKey: "first_name")
        let last = defaults.string(forKey: "last_name")
        let email = defaults.string(forKey: "email")
        let phone = defaults.string(forKey: "phone")
        
        self.phoneTextFeild.text = phone
        self.firstNameTextFeild.text = first
        self.lastNameTextFeild.text = last
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func joinGroup(_ sender: Any) {
        if (MyVriables.currentMember?.id)! != -1 {
        if MyVriables.roleStatus == "observer" {
            joinGroupRequest()
        }
        else {
            changeStatusTo(type: "observer")

        }
        }
        else {
            let snackbar = TTGSnackbar(message: "Please Login in the header and after you can join to the group !", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }


    }
    func joinGroupRequest(){
        print(ApiRouts.Web + "/api/groups/join/\((MyVriables.currentGroup?.id!)!)/\((MyVriables.currentMember?.id!)!)/member"+"    Leave GROUP")
        HTTP.POST(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/join", parameters: []) { response in
            if response.error != nil {
                print("errory \(response.error?.localizedDescription)")
                
                return
            }else{
                DispatchQueue.main.sync {
                    
                    MyVriables.currentGroup?.role = "member"
                    SwiftEventBus.post("refreshGroupChangeRole")
                        print("Sucess and role after  = \(MyVriables.currentGroup?.role!)")
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")

                    }
                    MyVriables.shouldRefresh = true
                    self.showToast("You'v left the group successfully", 0.3)
                    self.changeStatusTo(type: "member")
                }
                print("descc "+response.description)
        
            }
        }
    }
    
    @IBAction func leaveGroup(_ sender: Any) {
        print(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave"+"    JOIN GROUP")
        HTTP.DELETE(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave") { response in
            //do things...
            if response.error != nil {
                print("errory \(response.error)")
                return
            }else{
                print("descc "+response.description)
                DispatchQueue.main.sync {
                    SwiftEventBus.post("refreshGroupChangeRole")
                    MyVriables.currentGroup?.role = "observer"

                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        MyVriables.CurrentTopic = "IOS-Group-\(String(describing: (MyVriables.currentGroup?.id!)!))"
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().unsubscribe(fromTopic: "/topics/IOS-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")
                    }
                    
                    self.showToast("You'v joind the group successfully", 0.3)
                    self.leaveGroupRequest()
                }
            }
        }
    }
    
    
    func leaveGroupRequest(){
        print("LEAVE GROUP REQUEST PRESSED")
        MyVriables.shouldRefresh = true
        self.navigationController?.popViewController(animated: true)
    }
    func changeStatusTo(type: String){
        if type == "member" {
            MyVriables.roleStatus = "member"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
            self.tabBarController?.tabBar.items![1].title = "Joined"
            self.tabBarController?.selectedIndex = 0
        }
        if type == "observer" {
            MyVriables.roleStatus = "observer"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
            self.tabBarController?.tabBar.items![1].title = "Join"
            self.tabBarController?.selectedIndex = 0
        }
        if type == "null" {
            MyVriables.roleStatus = "null"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
            self.tabBarController?.tabBar.items![1].title = "Join"
            self.tabBarController?.selectedIndex = 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender = genderData[row]
        print(gender)
    }

}
