//
//  PrivacyViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 3.6.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        checkAllSwitch.addTarget(self, action: #selector(self.switchChangeed(_:)), for: .valueChanged)
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
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        arrayGdpr.append(GdprObject(title: "Profile details", descrption: "Full name, profile image, date of birth and gender and hometown. These details will be saved to identify you among other members and will be displayed for members on the app. You can choose not to provide any of all of these details.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Phone number and receiving text messages (required)", descrption: "The phone number will be used as your username and will also be used to invite you to a group. Your number will be visible to group leaders and they would be able to call you. You will also receive sms messages for verification purposes and for group invitation.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Groups relations (required)", descrption: "Every group you decide to join will be saved in our database. Your profile will be displayed as a member on those groups and the group leader will be able to send you updates, ask you for file upload and manage you as a group member", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Chat messaging (required)", descrption: "You approve we can save your text and media you share using the private and group chats. Messages you send through the private chat will be visible only to you and your chat participant. Messages sent on the group chat will be available to all of the groups members", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Pairing (required)", descrption: "You have the option to join a fellow group members as a pair so you can share bedrooms, bus seats and more. The members you pair with will be displayed to other group members.", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Real time Location", descrption: "Your group members may have the option to see your location on a map. You will be able to see the group members on a real time map using GPS positioning. You may disable this option on the settings page", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Push notifications", descrption: "Snapgroup may send you push notifications from time to time (only for mobile apps). The push notifications can be for groups invitations, group leader updates or system messages of any type. You can disable each type of push messages on the settings page", isChecked: false))
        arrayGdpr.append(GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: false))
        
    }
    
    
    

    
   
    
    //  var arraySiwtch = [Bool](repeating:false, count: 9)
    
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayGdpr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GdbrCell", for: indexPath) as! PrivacyCell
        cell.selectionStyle = .none
        print("Value is \(arrayGdpr[indexPath.row].isChecked)")
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
    
    
    

}
