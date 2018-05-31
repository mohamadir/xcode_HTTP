//
//  MemberModalViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/8/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import TTGSnackbar
import SwiftEventBus
import SwiftHTTP

class MemberModalViewController: UIViewController {
    var currentMember: GroupMember?
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var memberRoleLbl: UILabel!
    @IBOutlet weak var memberOriginLbl: UILabel!
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var pairText: UILabel!
    @IBOutlet weak var pairIcon: UIImageView!
    @IBOutlet weak var pairView: UIView!
    @IBOutlet weak var memberNameLbl: UILabel!
    @IBOutlet weak var chatIcon: UIButton!
    
    fileprivate func setPair() {
        if (GroupMembers.currentMemmber?.status) != nil {
            print("Status is \((GroupMembers.currentMemmber?.status)!)")
            if ((GroupMembers.currentMemmber?.status)!=="paired") {
                pairText.text = "Paired"
                pairText.textColor = UIColor.gray
                pairIcon.image = UIImage(named: "Pair")
                
            }
            if ((GroupMembers.currentMemmber?.status)!=="pending") {
                pairText.text = "Wait pair confirmation"
                pairText.textColor = UIColor.gray
                pairIcon.image = UIImage(named: "Pair")

            }
            if ((GroupMembers.currentMemmber?.status)!=="rejected") {
                pairText.text = "Deny pairing"
                pairText.textColor = UIColor.gray
                pairIcon.image = UIImage(named: "Pair")
            }
        }
    }
    
    fileprivate func showPairModal() {
        let VerifyAlert = UIAlertController(title: "Pair with \((GroupMembers.currentMemmber?.first_name)!) \((GroupMembers.currentMemmber?.last_name)!)", message: "Pairing allows you to request from the group leader to relate to you and your paired friend as a couple or group. For example to share a room, to sit next to each other during meals or trips, etc.", preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Request Pairung", comment: "Default action"), style: .`default`, handler: { _ in
            
            self.sendPair()
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
     
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    fileprivate func cancelPair() {
        let VerifyAlert = UIAlertController(title: "Pair with \((GroupMembers.currentMemmber?.first_name)!) \((GroupMembers.currentMemmber?.last_name)!)", message: "Would you like to cancel the pairing with this member?" + "\nIf you already sent a paring request, it will be canceled", preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel pairing", comment: "Default action"), style: .`default`, handler: { _ in
            self.removePair()
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Stay paired", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
            
            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == true{
            print("Current member is == \((GroupMembers.currentMemmber?.id)!) and My id is \((MyVriables.currentMember?.id)!)")
            if (MyVriables.currentGroup?.role) != nil && (MyVriables.currentGroup?.role)! != "observer" && (MyVriables.currentMember?.id)! != (GroupMembers.currentMemmber?.id)! {
                chatIcon.isHidden = false
                pairView.isHidden = false
            }
             else {
            pairView.isHidden = true
            chatIcon.isHidden = true
            }
        }
        else {
           pairView.isHidden = true
            chatIcon.isHidden = true
        }
        setPair()
        self.currentMember = GroupMembers.currentMemmber
        pairView.addTapGestureRecognizer {
            if (MyVriables.currentGroup?.role) != nil && (MyVriables.currentGroup?.role)! != "observer" {
                if (GroupMembers.currentMemmber?.status) != nil {
                     if ((GroupMembers.currentMemmber?.status)!=="pending" || (GroupMembers.currentMemmber?.status)!=="paired") {
                        
                        self.cancelPair()
                     }
                     else {
                        
                        self.showPairModal()
                    }
                }
                else
                {
                     self.showPairModal()
                }
            }
            else {
                let snackbar = TTGSnackbar(message: "You must to join group to make Pair with group's members", duration: .middle)
                snackbar.icon = UIImage(named: "AppIcon")
                snackbar.show()
          
            }
        }
        setLayoutShadow()
        setMemberDetails()
        // Do any additional setup after loading the view.
    }
    @IBAction func chatClick(_ sender: Any) {
        
        SwiftEventBus.post("GoToPrivateChat")
        isChatId = false
        var ProfileImage: String = ""
        if (self.currentMember?.profile_image) != nil {
            ProfileImage = (self.currentMember?.profile_image!)!
        }
        print("profile_image: \(ProfileImage)")
        
        ChatUser.currentUser = Partner(id: (self.currentMember?.id)!, email: (self.currentMember?.email)!, profile_image: ProfileImage , first_name: (self.currentMember?.first_name)! , last_name: (self.currentMember?.last_name)!)
        dismiss(animated: true, completion: nil)
        
    }
   
    func setLayoutShadow(){
        memberView.layer.shadowColor = UIColor.black.cgColor
        memberView.layer.shadowOpacity = 0.5
        memberView.layer.shadowOffset = CGSize.zero
        memberView.layer.shadowRadius = 4
        
    }
    
    func setMemberDetails(){
        print((self.currentMember?.first_name!)! + " " + (currentMember?.last_name!)!)
        memberNameLbl.text = (self.currentMember?.first_name!)! + " " + (currentMember?.last_name!)!
        self.memberRoleLbl.text = currentMember?.role!
        if currentMember?.role! == "group_leader" {
            self.memberRoleLbl.text = "Group Leader"
        }
        if currentMember?.profile_image != nil {
            var urlString = ApiRouts.Web + (currentMember?.profile_image)!
            print(urlString)
            if currentMember?.profile_image?.contains("https") == true {
                print("in IF ")
                urlString =  (currentMember?.profile_image)!
            }
            let url = URL(string: urlString)
            
           memberImageView.downloadedFrom(url: url!)
        }
        
    }
    func sendPair(){
        
        print("Url send Pair is " + ApiRouts.Web+"/api/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)")
        HTTP.POST(ApiRouts.Web+"/api/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)", parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do{
            
                DispatchQueue.main.sync {
                    SwiftEventBus.post("refreshMembers")
                    GroupMembers.currentMemmber?.status = "pending"
                    self.pairText.text = "Wait pair confirmation"
                    self.pairText.textColor = UIColor.gray
                    self.pairIcon.image = UIImage(named: "Pair")
                }
                
            }            catch let _ {
                
            }
            
        }
    }
    func removePair(){
        print("Url send Pair is " + ApiRouts.Web+"/api/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)")
        HTTP.DELETE(ApiRouts.Web+"/api/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)", parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do{
                
                DispatchQueue.main.sync {
                    SwiftEventBus.post("refreshMembers")

                    self.pairText.text = "Pair with this member"
                    GroupMembers.currentMemmber?.status = nil
                    self.pairText.textColor = Colors.PrimaryColor
                    self.pairIcon.image = UIImage(named: "Pair")
                }
                
            }
            catch let error {
                
            }
            
        }
    }
   
    @IBAction func onCloseTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
