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
    
    @IBAction func showGroupPressed(_ sender: Any) {
        getGroup()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    
    @IBAction func rejectPressed(_ sender: Any) {
        
    }
    func getGroup(){
        HTTP.GET(ApiRouts.Web + "/api/groups/\((MyVriables.currentInboxMessage?.group_id!)!)/details/\((MyVriables.currentMember?.id!)!)"){response in
            
            if response.error != nil {
                self.showCloseAlert()
                return
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
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
