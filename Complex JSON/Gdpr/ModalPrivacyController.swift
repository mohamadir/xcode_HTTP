//
//  ModalPrivacyController.swift
//  Snapgroup
//
//  Created by snapmac on 6/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus
import SwiftHTTP
import TTGSnackbar
import FBSDKLoginKit
import FBSDKCoreKit


class ModalPrivacyController: UIViewController {

    @IBOutlet weak var deleteLbl: UIButton!
    @IBOutlet weak var titleSwitch: UILabel!
    @IBOutlet weak var siwtch: UISwitch!
    @IBOutlet weak var labelSwitch: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         siwtch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        if MyVriables.currentGdbr?.isDeleteAcount == false
        {
            deleteLbl.setTitle("Continue", for: .normal)
            titleSwitch.text = MyVriables.currentGdbr?.title
            deleteLbl.setTitleColor(Colors.PrimaryColor, for: .normal)
            labelSwitch.text = MyVriables.currentGdbr?.description
        }
        else
        {
            labelSwitch.text =  "Unfortunbatley, you cannot have a count in Snapgroup without accepting this term"
             titleSwitch.text = "Delete my account"
            deleteLbl.setTitle("Delete", for: .normal)
            deleteLbl.setTitleColor(UIColor.red, for: .normal)
        }

    }
    @IBAction func deleteAccount(_ sender: Any) {
        if siwtch.isOn == true {
            if MyVriables.currentGdbr?.isDeleteAcount == true
            {
                deleteMemberFunc()
            }
            else
            {
                setCheck(isChecked: false, chekAll: false, postion: -1)
                
            }

            
        } else {
            let snackbar = TTGSnackbar(message: "please check the switch to true to delete your account!", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
       
    }
    @IBAction func backclick(_ sender: Any) {
        MyVriables.currentMember?.gdpr?.checkAllSwitch = true
        SwiftEventBus.post("setCheck")
        
        dismiss(animated: true,completion: nil)
    }
    @IBAction func dismissPage(_ sender: Any) {
        SwiftEventBus.post("setCheck")
        MyVriables.currentMember?.gdpr?.checkAllSwitch = true
        dismiss(animated: true,completion: nil)
        
    }
    func deleteMemberFunc(){
        print("\(ApiRouts.Web)/api/members/\((MyVriables.currentMember?.id)!)")
        HTTP.DELETE("\(ApiRouts.Api)/members/\((MyVriables.currentMember?.id)!)") {
            response in
            if response.error != nil {
                print(response.error)
                return
            }
            do {
      MyVriables.currentMember?.gdpr? = GdprStruct(profile_details: false, phone_number: false, groups_relations: false, chat_messaging: false, pairing: false, real_time_location: false, files_upload: false, push_notifications: false, rating_reviews: false, group_details: false, billing_payments : false, checkAllSwitch: false)
                self.setToUserDefaults(value: false, key: "isLogged")
                self.setToUserDefaults(value: -1, key: "member_id")
                MyVriables.currentMember?.id = -1
                let defaults = UserDefaults.standard
                let dictionary = defaults.dictionaryRepresentation()
                dictionary.keys.forEach { key in
                    defaults.removeObject(forKey: key)
                }
                 let defaults2 = UserDefaults.standard
                let isLogged = defaults2.bool(forKey: "isLogged")
                print("Privacy modal Is logged = \(isLogged) after removed")
                do{ let loginManager = FBSDKLoginManager()
                    loginManager.logOut() // this is an instance function
                }
                catch {
                    
                }
                

                self.dismiss(animated: true,completion: nil)
                SwiftEventBus.post("setCheckTrue")
               
                SwiftEventBus.post("changeProfileInfooo")

            }
            catch {
                
            }
            
        }
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
    func setCheck(isChecked : Bool, chekAll : Bool, postion : Int){
        var params: [String: Any]
        params = [(MyVriables.currentGdbr?.gdbrParmter)!: isChecked]
        HTTP.PUT("\(ApiRouts.Api)/members/\((MyVriables.currentMember?.id)!)/gdpr", parameters: params) {
            response in
            if response.error != nil {
                //print(response.error)
                return
            }
            do {
                let gdprUpdate : GdprUpdate = try JSONDecoder().decode(GdprUpdate.self, from: response.data)
                MyVriables.currentMember?.gdpr = GdprStruct(profile_details: (gdprUpdate.gdpr?.profile_details)!, phone_number: (gdprUpdate.gdpr?.phone_number)!, groups_relations: (gdprUpdate.gdpr?.groups_relations)!, chat_messaging: (gdprUpdate.gdpr?.chat_messaging)!, pairing: (gdprUpdate.gdpr?.pairing)!, real_time_location: (gdprUpdate.gdpr?.real_time_location)!, files_upload: (gdprUpdate.gdpr?.files_upload)!, push_notifications: (gdprUpdate.gdpr?.push_notifications)!, rating_reviews: (gdprUpdate.gdpr?.rating_reviews)!, group_details: (gdprUpdate.gdpr?.profile_details)!, billing_payments : true, checkAllSwitch: true)
                SwiftEventBus.post("shouldRefreshGdpr")
                 SwiftEventBus.post("changeProfileInfo")
                 self.dismiss(animated: true,completion: nil)
            }
            catch {
                
            }
            
        }
        
    }
    
    

}

