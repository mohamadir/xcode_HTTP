//
//  MessageViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/23/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
struct InboxGroup: Codable {
    var group: TourGroup?
}
class MessageViewController: UIViewController {

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var pairView: UIView!
    @IBOutlet weak var messageTitlelbl: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var showGroupButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pairStatusLbl: UILabel!
    @IBOutlet weak var rejectBt: UIButton!
    @IBOutlet weak var acceptBt: UIButton!
    @IBOutlet weak var removePairBt: UIButton!
    
   
    @IBAction func showGroupPressed(_ sender: Any) {
        getGroup()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.addTapGestureRecognizer {
        self.navigationController?.popViewController(animated: true)
        }
        if MyVriables.currentInboxMessage?.type! == "invite_group" {
            messageTitlelbl.text = "Group invitation"
            subjectLbl.text = MyVriables.currentInboxMessage?.subject!
            messageLbl.text = MyVriables.currentInboxMessage?.body!
            pairView.isHidden = true
            
        }
        
        if MyVriables.currentInboxMessage?.type! == "notification" {
            subjectLbl.text = MyVriables.currentInboxMessage?.subject!
            messageTitlelbl.text = "Group leader Message"
            messageLbl.text = MyVriables.currentInboxMessage?.body!
            pairView.isHidden = true

        }
        
        if MyVriables.currentInboxMessage?.type! == "invite" {
            subjectLbl.text = (MyVriables.currentInboxMessage?.first_name!)! + " " + (MyVriables.currentInboxMessage?.last_name!)! + " wants to pair with you in group."
            messageTitlelbl.text = "Pair with friend"
            messageLbl.text = "Do you want to pair with " + (MyVriables.currentInboxMessage?.first_name!)! + " " + (MyVriables.currentInboxMessage?.last_name!)! + " ?"
            pairStatusLbl.textColor = Colors.PrimaryColor
            if MyVriables.currentInboxMessage?.accepted == "true" {
                setPairStatus(true)
            }
            
            if MyVriables.currentInboxMessage?.accepted == "pending" {
                acceptBt.isHidden = false
                rejectBt.isHidden = false
                pairStatusLbl.isHidden = true
                removePairBt.isHidden = true
            }
            
            if MyVriables.currentInboxMessage?.accepted == "false" {
                setPairStatus(false)
            }
        }
        
        dateLbl.text = MyVriables.currentInboxMessage?.created_at!
        
        
        // Do any additional setup after loading the view.
    }
    func setPairStatus(_ accepted: Bool){
        acceptBt.isHidden = true
        rejectBt.isHidden = true
        pairStatusLbl.isHidden = false
        removePairBt.isHidden = false
        if accepted {
            pairStatusLbl.text = "Pair accepted"
        }
        else {
            pairStatusLbl.text = "Pair rejected"

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptPressed(_ sender: Any) {
        setPair(sender_id: (MyVriables.currentInboxMessage?.sender_id!)!, reciever_id: (MyVriables.currentMember?.id!)!, group_id: (MyVriables.currentInboxMessage?.group_id!)!, approaved: "accept")
    }
    
    @IBAction func rejectPressed(_ sender: Any) {
        setPair(sender_id: (MyVriables.currentInboxMessage?.sender_id!)!, reciever_id: (MyVriables.currentMember?.id!)!, group_id: (MyVriables.currentInboxMessage?.group_id!)!, approaved: "decline")
    }
    
    @IBAction func removePairPressed(_ sender: Any) {
        removePair(sender_id: (MyVriables.currentInboxMessage?.sender_id!)!, reciever_id: (MyVriables.currentMember?.id!)!, group_id: (MyVriables.currentInboxMessage?.group_id!)!)
    }
    
    func setPair(sender_id: Int, reciever_id: Int,group_id: Int, approaved: String){
        print("message details: \(sender_id) \(reciever_id) \(group_id) \(approaved)")
        HTTP.PUT(ApiRouts.Api + "/pairs?sender_id=\(sender_id)&receiver_id=\(reciever_id)&group_id=\(group_id)&type=\(approaved)"){response in
            if response.error != nil {
                print("setPair: \(response.error)")
                return
            }else {
                MyVriables.MemberInboxShouldRefresh = true
                if approaved == "accept" {
                    
                    DispatchQueue.main.sync {
                        self.setPairStatus(true)
                    }
                    
                }else {
                    
                    DispatchQueue.main.sync {
                        self.setPairStatus(false)
                    }
                }
            }
        }
    }
    func removePair(sender_id: Int, reciever_id: Int,group_id: Int){
        HTTP.DELETE(ApiRouts.Api + "/pairs?sender_id=\(sender_id)&receiver_id=\(reciever_id)&group_id=\(group_id)"){response in
            if response.error != nil {
                print("setPair: \(response.error)")
                return
            }else {
                    DispatchQueue.main.sync {
                        MyVriables.MemberInboxShouldRefresh = true
                        self.navigationController?.popViewController(animated: true)
                    }
               
            }
        }
    }
    
    func getGroup(){
        print(ApiRouts.ApiV3 + "/groups/\(((MyVriables.currentInboxMessage?.group_id!)!))?member_id=\(((MyVriables.currentMember?.id)!))")
        HTTP.GET(ApiRouts.ApiV3 + "/groups/\(((MyVriables.currentInboxMessage?.group_id!)!))?member_id=\(((MyVriables.currentMember?.id)!))"){response in
            if response.error != nil {
                self.showCloseAlert()
                return
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                print("Group \(group2.group)")
                MyVriables.currentGroup = group2.group
                DispatchQueue.main.sync {
                    self.performSegue(withIdentifier: "showGroup", sender: self)
                }
            }
            catch let error{
                print("getGroup : \(error)")

            }
        }
    }
    
    func showCloseAlert(){
        let alert = UIAlertController(title: "You are not able to see this group, please contact the group leader", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    

}
