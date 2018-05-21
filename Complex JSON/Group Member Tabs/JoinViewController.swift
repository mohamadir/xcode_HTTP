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
    
      
    }
    func showToast(_ message: String,_ duration: Double){
        var style = ToastStyle()
        // this is just one of many style options
        style.messageColor = .white
        // present the toast with the new style
        self.view.makeToast(message, duration: duration, position: .bottom, style: style)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("roleStatus" +  MyVriables.roleStatus)
        if MyVriables.roleStatus == "member" {
            observerView.isHidden = true
            memberView.isHidden = false
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joined")
            self.tabBarController?.tabBar.items![1].title = "Joined"
            self.tabBarController?.tabBar.items![1].selectedImage =  UIImage(named: "joined")

            
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
        self.phoneTextFeild.isEnabled = false
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func joinGroup(_ sender: Any) {
        if MyVriables.roleStatus == "observer" {
            joinGroupRequest()
        }
        else {
            changeStatusTo(type: "observer")

        }


    }
    func joinGroupRequest(){
        print(ApiRouts.Web + "/api/groups/join/\((MyVriables.currentGroup?.id!)!)/\((MyVriables.currentMember?.id!)!)/member")
        HTTP.POST(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/join", parameters: []) { response in
            if response.error != nil {
                print("errory \(response.error?.localizedDescription)")
                
                return
            }else{
                DispatchQueue.main.sync {
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-Group-\(String(describing: (MyVriables.currentGroup?.id!)!))")
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
        print(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave")
        HTTP.DELETE(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave") { response in
            //do things...
            if response.error != nil {
                print("errory \(response.error)")
                
                return
            }else{
                print("descc "+response.description)
                DispatchQueue.main.sync {
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        MyVriables.CurrentTopic = "IOS-Group-\(String(describing: (MyVriables.currentGroup?.id!)!))"
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().unsubscribe(fromTopic: "/topics/IOS-Group-\(String(describing: (MyVriables.currentGroup?.id!)!))")
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
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joined")
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
