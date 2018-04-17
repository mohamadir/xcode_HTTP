//
//  GroupLeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
class GroupLeaderViewController: UIViewController {
    // hi hi 
    @IBOutlet weak var leaderImageview: UIImageView!
    var singleGroup: TourGroup?
    @IBOutlet weak var leadeAboutLbl: UILabel!
    @IBOutlet weak var activeGroupLbl: UILabel!
    @IBOutlet weak var leaderEmailLbl: UILabel!
    @IBOutlet weak var leaderGenderLbl: UILabel!
    @IBOutlet weak var leaderBiryhdayLbl: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var leaderNameLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.singleGroup  = MyVriables.currentGroup!
        
        groupNameLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : "There is no group name"
        activeGroupLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : ""
        leadeAboutLbl.text = singleGroup?.group_leader_about != nil ? singleGroup?.group_leader_about : "There no description right now"
        leaderEmailLbl.text = singleGroup?.group_leader_email != nil ? singleGroup?.group_leader_email : "There is no email"
        leaderGenderLbl.text = singleGroup?.group_leader_gender != nil ? singleGroup?.group_leader_gender : "There is no gender"
        leaderBiryhdayLbl.text = singleGroup?.group_leader_birth_date != nil ? singleGroup?.group_leader_birth_date : "There is no Birthday"
        leaderNameLbl.text = singleGroup?.group_leader_first_name != nil ? singleGroup?.group_leader_first_name : ""
        do{
            if singleGroup?.group_leader_image != nil{
                let urlString = try ApiRouts.Web + (singleGroup?.group_leader_image)!
                var url = URL(string: urlString)
                leaderImageview.sd_setImage(with: url!, completed: nil)
            }
        }catch let error {
            print(error)
        }
        
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}

