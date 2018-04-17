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
class JoinViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
   
    
    var gender: String = "Male"
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var phoneTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var observerView: UIView!
    @IBOutlet weak var memberView: UIView!
    let genderData: [String] = ["Male","Female","Other"]
    override func viewDidLoad() {
        super.viewDidLoad()
    
      
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
        
        self.phoneTextFeild.isEnabled = false
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func joinGroup(_ sender: Any) {
        if MyVriables.roleStatus == "observer" {
            changeStatusTo(type: "member")
        }
        else {
            changeStatusTo(type: "observer")

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
            }
        }
    }
    
    func leaveGroupRequest(){
        
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
