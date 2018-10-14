//
//  PrivacyViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 3.6.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus
import SwiftHTTP

class PrivacyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var isAllChecked : Bool = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkAllSwitch: UISwitch!
    var currentProfile: MemberProfile?
    var currentMember: CurrentMember?
    var PINCODE: String?
    var phoneNumber: String?
    var arrayGdpr : [GdprObject] = []
    var arraySiwtch = [Bool](repeating:false, count: 9)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //shouldRefreshGdpr
        SwiftEventBus.onMainThread(self, name: "shouldRefreshGdpr") { result in
            self.arrayGdpr = []
             self.arrayGdpr.append(GdprObject(title: "", descrption: "", isChecked:  false, parmter: "", image: ""))
            self.arrayGdpr.append(GdprObject(title: "Profile details (required)", descrption: "Full name, profile image, date of birth and gender and hometown. These details will be saved to identify you among other members and will be displayed for members on the app. You can choose not to provide any of all of these details.", isChecked: (MyVriables.currentMember?.gdpr?.profile_details) != nil ? (MyVriables.currentMember?.gdpr?.profile_details)! : false, parmter: "profile_details", image: "PrivacyPageProfile"))
            self.arrayGdpr.append(GdprObject(title: "Phone number and receiving text messages (required)", descrption: "The phone number will be used as your username and will also be used to invite you to a group. Your number will be visible to group leaders and they would be able to call you. You will also receive sms messages for verification purposes and for group invitation.", isChecked: (MyVriables.currentMember?.gdpr?.phone_number) != nil ? (MyVriables.currentMember?.gdpr?.phone_number)! : false, parmter: "phone_number", image: "PrivacyPagePhoneNumber"))
            self.arrayGdpr.append(GdprObject(title: "Groups relations (required)", descrption: "Every group you decide to join will be saved in our database. Your profile will be displayed as a member on those groups and the group leader will be able to send you updates, ask you for file upload and manage you as a group member", isChecked: (MyVriables.currentMember?.gdpr?.groups_relations) != nil ? (MyVriables.currentMember?.gdpr?.groups_relations)! : false, parmter: "groups_relations", image: "PrivacyPageGroupRelation"))
            self.arrayGdpr.append(GdprObject(title: "Chat messaging (required)", descrption: "You approve we can save your text and media you share using the private and group chats. Messages you send through the private chat will be visible only to you and your chat participant. Messages sent on the group chat will be available to all of the groups members", isChecked: (MyVriables.currentMember?.gdpr?.chat_messaging) != nil ? (MyVriables.currentMember?.gdpr?.chat_messaging)! : false, parmter: "chat_messaging", image: "PrivacyPageChat"))
            self.arrayGdpr.append(GdprObject(title: "Pairing (required)", descrption: "You have the option to join a fellow group members as a pair so you can share bedrooms, bus seats and more. The members you pair with will be displayed to other group members.", isChecked: (MyVriables.currentMember?.gdpr?.pairing) != nil ? (MyVriables.currentMember?.gdpr?.pairing)! : false, parmter: "pairing", image: "PrivacyPagePairing"))
            self.arrayGdpr.append(GdprObject(title: "Real time Location", descrption: "Your group members may have the option to see your location on a map. You will be able to see the group members on a real time map using GPS positioning. You may disable this option on the settings page", isChecked: (MyVriables.currentMember?.gdpr?.real_time_location) != nil ? (MyVriables.currentMember?.gdpr?.real_time_location)! : false, parmter: "real_time_location", image: "PrivacyPageLocation"))
            self.arrayGdpr.append(GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false, parmter: "files_upload", image: "PrivacyPageFiles"))
            self.arrayGdpr.append(GdprObject(title: "Push notifications", descrption: "Snapgroup may send you push notifications from time to time (only for mobile apps). The push notifications can be for groups invitations, group leader updates or system messages of any type. You can disable each type of push messages on the settings page", isChecked: (MyVriables.currentMember?.gdpr?.push_notifications) != nil ? (MyVriables.currentMember?.gdpr?.push_notifications)! : false, parmter: "push_notifications", image: "PrivacyPageNotifications"))
            self.arrayGdpr.append(GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: (MyVriables.currentMember?.gdpr?.rating_reviews) != nil ? (MyVriables.currentMember?.gdpr?.rating_reviews)! : false, parmter: "rating_reviews", image: "PrivacyPageRaiting"))
            if (MyVriables.currentMember?.gdpr?.push_notifications) != nil
            {
                print("Gdpr notfication is \((MyVriables.currentMember?.gdpr?.push_notifications)!)")
                if (MyVriables.currentMember?.gdpr?.push_notifications)! == false
                {
                    UIApplication.shared.unregisterForRemoteNotifications()
                }
                else
                {
                    SwiftEventBus.post("registerRemote")
                }
                
            }else
            {
                print("Gdpr notfication is Nil")
            }
            self.checkAllTrue()
        }
   
        SwiftEventBus.onMainThread(self, name: "setCheck") { result in
            self.checkAllTrue()
            print("Is checked = \(self.checkAllSwitch.isOn)")
        }
        checkAllSwitch.addTarget(self, action: #selector(switchAllChnage), for: UIControlEvents.valueChanged)
        self.arrayGdpr = []
        self.arrayGdpr.append(GdprObject(title: "", descrption: "", isChecked:  false, parmter: "", image: ""))
        self.arrayGdpr.append(GdprObject(title: "Profile details (required)", descrption: "Full name, profile image, date of birth and gender and hometown. These details will be saved to identify you among other members and will be displayed for members on the app. You can choose not to provide any of all of these details.", isChecked: (MyVriables.currentMember?.gdpr?.profile_details) != nil ? (MyVriables.currentMember?.gdpr?.profile_details)! : false, parmter: "profile_details", image: "PrivacyPageProfile"))
        self.arrayGdpr.append(GdprObject(title: "Phone number and receiving text messages (required)", descrption: "The phone number will be used as your username and will also be used to invite you to a group. Your number will be visible to group leaders and they would be able to call you. You will also receive sms messages for verification purposes and for group invitation.", isChecked: (MyVriables.currentMember?.gdpr?.phone_number) != nil ? (MyVriables.currentMember?.gdpr?.phone_number)! : false, parmter: "phone_number", image: "PrivacyPagePhoneNumber"))
        self.arrayGdpr.append(GdprObject(title: "Groups relations (required)", descrption: "Every group you decide to join will be saved in our database. Your profile will be displayed as a member on those groups and the group leader will be able to send you updates, ask you for file upload and manage you as a group member", isChecked: (MyVriables.currentMember?.gdpr?.groups_relations) != nil ? (MyVriables.currentMember?.gdpr?.groups_relations)! : false, parmter: "groups_relations", image: "PrivacyPageGroupRelation"))
        self.arrayGdpr.append(GdprObject(title: "Chat messaging (required)", descrption: "You approve we can save your text and media you share using the private and group chats. Messages you send through the private chat will be visible only to you and your chat participant. Messages sent on the group chat will be available to all of the groups members", isChecked: (MyVriables.currentMember?.gdpr?.chat_messaging) != nil ? (MyVriables.currentMember?.gdpr?.chat_messaging)! : false, parmter: "chat_messaging", image: "PrivacyPageChat"))
        self.arrayGdpr.append(GdprObject(title: "Pairing (required)", descrption: "You have the option to join a fellow group members as a pair so you can share bedrooms, bus seats and more. The members you pair with will be displayed to other group members.", isChecked: (MyVriables.currentMember?.gdpr?.pairing) != nil ? (MyVriables.currentMember?.gdpr?.pairing)! : false, parmter: "pairing", image: "PrivacyPagePairing"))
        self.arrayGdpr.append(GdprObject(title: "Real time Location", descrption: "Your group members may have the option to see your location on a map. You will be able to see the group members on a real time map using GPS positioning. You may disable this option on the settings page", isChecked: (MyVriables.currentMember?.gdpr?.real_time_location) != nil ? (MyVriables.currentMember?.gdpr?.real_time_location)! : false, parmter: "real_time_location", image: "PrivacyPageLocation"))
        self.arrayGdpr.append(GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false, parmter: "files_upload", image: "PrivacyPageFiles"))
        self.arrayGdpr.append(GdprObject(title: "Push notifications", descrption: "Snapgroup may send you push notifications from time to time (only for mobile apps). The push notifications can be for groups invitations, group leader updates or system messages of any type. You can disable each type of push messages on the settings page", isChecked: (MyVriables.currentMember?.gdpr?.push_notifications) != nil ? (MyVriables.currentMember?.gdpr?.push_notifications)! : false, parmter: "push_notifications", image: "PrivacyPageNotifications"))
        self.arrayGdpr.append(GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: (MyVriables.currentMember?.gdpr?.rating_reviews) != nil ? (MyVriables.currentMember?.gdpr?.rating_reviews)! : false, parmter: "rating_reviews", image: "PrivacyPageRaiting"))
       checkAllTrue()

        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        checkAllSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SwiftEventBus.onMainThread(self, name: "setCheckTrue") { result in
            
            print("before pop ti root view controler swift")
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
      
       // checkAllTrue()
    }
    @objc func switchAllChnage(mySwitch: UISwitch) {
       
        print("mySwitch.isOn \(checkAllSwitch.isOn)")
        if mySwitch.isOn == false {
            MyVriables.currentGdbr = ModalGDPR(title: "check all", description: "", gdbrParmter: "all", isDeleteAcount: true)
            performSegue(withIdentifier: "showDialogGdpr", sender: self)
        }
        else {
            if mySwitch.isOn == true {
            self.setCheck(isChecked : true, chekAll : true, postion : -1)
            }
        }

    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayGdpr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GdbrCell", for: indexPath) as! PrivacyCell
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderPrivacyCell", for: indexPath) as! HeaderPrivacyCell
        if indexPath.row == 0
        {
            headerCell.checkAllSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            cell.selectionStyle = .none
            headerCell.checkAllSwitch.setOn(self.arrayGdpr[0].isChecked, animated: false)
            headerCell.checkAllSwitch.tag = 0
            headerCell.checkAllSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            return headerCell
        }
        else
        {
        cell.selectionStyle = .none
        print("Value is \(arrayGdpr[indexPath.row].isChecked)")
        cell.checkSwitch.setOn(arrayGdpr[indexPath.row].isChecked, animated: false)
        cell.checkSwitch.tag = indexPath.row // for detect which row switch Changed
        cell.checkSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.imageGdpr.image = UIImage(named: arrayGdpr[indexPath.row].image)
        cell.checkSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cell.title.text = arrayGdpr[indexPath.row].title
        cell.discrption.text = arrayGdpr[indexPath.row].descrption
        
        return cell
        }
    }
    @objc func switchChanged(_ sender : UISwitch!){
        print("Sender tag is \(sender.tag)")
        if sender.isOn == false {
        if (sender.tag == 5 || sender.tag == 1 || sender.tag == 2 || sender.tag == 3 || sender.tag == 4)
        {
            print("is in 1 - 5")

            MyVriables.currentGdbr = ModalGDPR(title: "check all", description: "", gdbrParmter: "all", isDeleteAcount: true)
              sender.isOn = true
            performSegue(withIdentifier: "showDialogGdpr", sender: self)
            
           
        }
        else {
            print("is in 0")
            if sender.tag == 0
            {
                print("Is all")
                    print("Is all to false")
                    MyVriables.currentGdbr = ModalGDPR(title: "check all", description: "", gdbrParmter: "all", isDeleteAcount: true)
                    sender.isOn = true
                    performSegue(withIdentifier: "showDialogGdpr", sender: self)
                
            }
            else {
            print("is in else ")
            sender.isOn = true
            MyVriables.currentGdbr = ModalGDPR(title: arrayGdpr[sender.tag].title, description: arrayGdpr[sender.tag].descrption, gdbrParmter: arrayGdpr[sender.tag].parmter, isDeleteAcount: false)
            performSegue(withIdentifier: "showDialogGdpr", sender: self)
            //setCheck(isChecked: false, chekAll: false, postion: sender.tag)
            }
            }
            
        }
        else {
            if sender.isOn == true {
                print("Is all to true")
                if sender.tag == 0 {
                    self.setCheck(isChecked : true, chekAll : true, postion : -1)
                }
                else {
                setCheck(isChecked: true, chekAll: false, postion: sender.tag)
                arrayGdpr[sender.tag].isChecked = true
                }
               // checkAllTrue()
            }
        }
        
        
    }
    func checkAllTrue(){
        var count : Int = 0
        for indexi in 1...9 {
            print("Is checked  for theis item is \(indexi) is \(arrayGdpr[indexi].isChecked)")
            if arrayGdpr[indexi].isChecked == false
            {
                count = 1
                print(" false")
                 print("Is not checked  for theis item is \(indexi) is \(arrayGdpr[indexi].isChecked)")
            }
        }
        print("Count is \(count)")
        if count == 0 {
            isAllChecked = true
            self.arrayGdpr[0].isChecked = true
           // checkAllSwitch.isOn = true
        }
        else {
            isAllChecked = false
           // checkAllSwitch.isOn = false
        }
        tableView.reloadData()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrayGdpr[indexPath.row].isChecked = !arrayGdpr[indexPath.row].isChecked
        // arraySiwtch[indexPath.row] = !arraySiwtch[indexPath.row]
    }
    
    func switchChangeStateWithIndex(index:Int){
        //arraySiwtch[index] = !arraySiwtch[index]
        arrayGdpr[index].isChecked = !arrayGdpr[index].isChecked
    }
    func setCheck(isChecked : Bool, chekAll : Bool, postion : Int){
        var params: [String: Any] = ["" : true]
        if chekAll == true {
            params = ["chat_messaging": true,
                      "files_upload": true,
                      "groups_relations": true,
                      "pairing": true,
                      "phone_number": true,
                      "profile_details": true,
                      "push_notifications": true,
                      "real_time_location": true,
                      "rating_reviews": true]
        }
        else {
            params = [arrayGdpr[postion].parmter: isChecked]
        }
        HTTP.PUT("\(ApiRouts.Api)/members/\((MyVriables.currentMember?.id)!)/gdpr", parameters: params) {
            response in
            if response.error != nil {
                //print(response.error)
                return
            }
            do {
                let  gdprUpdate : GdprUpdate = try JSONDecoder().decode(GdprUpdate.self, from: response.data)
                MyVriables.currentMember?.gdpr = GdprStruct(profile_details: (gdprUpdate.gdpr?.profile_details)!, phone_number: (gdprUpdate.gdpr?.phone_number)!, groups_relations: (gdprUpdate.gdpr?.groups_relations)!, chat_messaging: (gdprUpdate.gdpr?.chat_messaging)!, pairing: (gdprUpdate.gdpr?.pairing)!, real_time_location: (gdprUpdate.gdpr?.real_time_location)!, files_upload: (gdprUpdate.gdpr?.files_upload)!, push_notifications: (gdprUpdate.gdpr?.push_notifications)!, rating_reviews: (gdprUpdate.gdpr?.rating_reviews)!, group_details: (gdprUpdate.gdpr?.profile_details)!, billing_payments : true, checkAllSwitch: true)
                 self.arrayGdpr[0].isChecked = (gdprUpdate.gdpr?.profile_details)!
                self.arrayGdpr[1].isChecked = (gdprUpdate.gdpr?.profile_details)!
                self.arrayGdpr[2].isChecked = (gdprUpdate.gdpr?.phone_number)!
                self.arrayGdpr[3].isChecked = (gdprUpdate.gdpr?.groups_relations)!
                self.arrayGdpr[4].isChecked = (gdprUpdate.gdpr?.chat_messaging)!
                self.arrayGdpr[5].isChecked = (gdprUpdate.gdpr?.pairing)!
                self.arrayGdpr[6].isChecked = (gdprUpdate.gdpr?.real_time_location)!
                self.arrayGdpr[7].isChecked = (gdprUpdate.gdpr?.files_upload)!
                self.arrayGdpr[8].isChecked = (gdprUpdate.gdpr?.push_notifications)!
                self.arrayGdpr[9].isChecked = (gdprUpdate.gdpr?.rating_reviews)!
                if postion != nil && postion < 10 && postion > 0 {
                    print("Postion is \(postion)")
                if self.arrayGdpr[postion].parmter == "push_notifications"
                {
                    SwiftEventBus.post("shouldRefreshGdpr")
                    SwiftEventBus.post("changeProfileInfo")
                }
                }
                DispatchQueue.main.async {
                self.checkAllTrue()
                }
            }
            catch {
                
            }
            
        }
    }
    
    
    

}
