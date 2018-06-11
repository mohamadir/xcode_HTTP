//
//  GdbrViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 27.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import SwiftEventBus

public  struct GdprObject {
    var title: String
    var descrption: String
    var isChecked: Bool
}
class GdbrViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentProfile: MemberProfile?
    var currentMember: CurrentMember?
    var PINCODE: String?
    var phoneNumber: String?
    @IBOutlet weak var tableViewGdpr: UITableView!
    @IBOutlet weak var checkAllSwitch: UISwitch!
   
  //  var arraySiwtch = [Bool](repeating:false, count: 9)
    var arrayGdpr : [GdprObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
       
        checkAllSwitch.addTarget(self, action: #selector(self.switchChangeed(_:)), for: .valueChanged)
        ////fill array
   // 2 3 4 5
        arrayGdpr.append(GdprObject(title: "Profile details", descrption: "Full name, profile image, date of birth and gender and hometown. These details will be saved to identify you among other members and will be displayed for members on the app. You can choose not to provide any of all of these details.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Phone number and receiving text messages (required)", descrption: "The phone number will be used as your username and will also be used to invite you to a group. Your number will be visible to group leaders and they would be able to call you. You will also receive sms messages for verification purposes and for group invitation.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Groups relations (required)", descrption: "Every group you decide to join will be saved in our database. Your profile will be displayed as a member on those groups and the group leader will be able to send you updates, ask you for file upload and manage you as a group member", isChecked: false))
         arrayGdpr.append(GdprObject(title: "Chat messaging (required)", descrption: "You approve we can save your text and media you share using the private and group chats. Messages you send through the private chat will be visible only to you and your chat participant. Messages sent on the group chat will be available to all of the groups members", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Pairing (required)", descrption: "You have the option to join a fellow group members as a pair so you can share bedrooms, bus seats and more. The members you pair with will be displayed to other group members.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Real time Location", descrption: "Your group members may have the option to see your location on a map. You will be able to see the group members on a real time map using GPS positioning. You may disable this option on the settings page", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Push notifications", descrption: "Snapgroup may send you push notifications from time to time (only for mobile apps). The push notifications can be for groups invitations, group leader updates or system messages of any type. You can disable each type of push messages on the settings page", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: false))

        
        
        
        tableViewGdpr.allowsSelection = false
        tableViewGdpr.delegate = self
        tableViewGdpr.dataSource = self
        checkAllSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        // Do any additional setup after loading the view.
        
    }

    @IBAction func dismissModal(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayGdpr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GdbrCell", for: indexPath) as! GdbrCell
        cell.selectionStyle = .none

        cell.checkSwitch.setOn(arrayGdpr[indexPath.row].isChecked, animated: true)
         cell.checkSwitch.tag = indexPath.row // for detect which row switch Changed
         cell.checkSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

         cell.checkSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cell.title.text = arrayGdpr[indexPath.row].title
         cell.discrption.text = arrayGdpr[indexPath.row].descrption
        
        return cell
    }
    @objc func switchChanged(_ sender : UISwitch!){
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")

        arrayGdpr[sender.tag].isChecked = !arrayGdpr[sender.tag].isChecked

    }
    @objc func switchChangeed(_ sender : UISwitch!){
        var booleaneSiwtch : Bool = false
        if checkAllSwitch.isOn == true {
            booleaneSiwtch = true
        }
        else { booleaneSiwtch = false }
        var indexi: Int = 0
        for indexi in 0...8 {
            arrayGdpr[indexi].isChecked = booleaneSiwtch
        }
        tableViewGdpr.reloadData()
       
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         arrayGdpr[indexPath.row].isChecked = !arrayGdpr[indexPath.row].isChecked
       // arraySiwtch[indexPath.row] = !arraySiwtch[indexPath.row]
    }
    
    func switchChangeStateWithIndex(index:Int){
        //arraySiwtch[index] = !arraySiwtch[index]
          arrayGdpr[index].isChecked = !arrayGdpr[index].isChecked
    }
    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }

    @IBAction func confirmClick(_ sender: Any) {
      //  print("THIS OK 2 = \(arraySiwtch[2]) 3 = \(arraySiwtch[2])")

        if  arrayGdpr[2].isChecked  == true &&  arrayGdpr[3].isChecked  == true  &&  arrayGdpr[4].isChecked  == true &&  arrayGdpr[1].isChecked  == true
        {
            var gdpr : GdprPost = GdprPost(profile_details: arrayGdpr[0].isChecked, phone_number: arrayGdpr[1].isChecked, groups_relations: arrayGdpr[2].isChecked, chat_messaging: arrayGdpr[3].isChecked, pairing: arrayGdpr[4].isChecked, real_time_location: arrayGdpr[5].isChecked, files_upload: arrayGdpr[6].isChecked, push_notifications: arrayGdpr[7].isChecked, rating_reviews: arrayGdpr[8].isChecked)
            MyVriables.arrayGdpr = gdpr
            self.dismiss(animated: true, completion: nil)
            if (MyVriables.fromGroup)! == "true-join"
            {
                MyVriables.fromGroup = ""
                MyVriables.joinToGroup = "yes-Join"
                 SwiftEventBus.post("refreshFromGroupJoin")
                
            }
            else
                    {
                        if (MyVriables.fromGroup)! == "true"
                        {
                            SwiftEventBus.post("refreshFromGroup")
                        }
                        else
                        {
                            SwiftEventBus.post("refreshGroups")

                        }
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
    
    
    

}

