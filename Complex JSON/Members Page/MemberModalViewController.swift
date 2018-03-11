//
//  MemberModalViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/8/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class MemberModalViewController: UIViewController {
    var currentMember: GroupMember?
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var memberRoleLbl: UILabel!
    @IBOutlet weak var memberOriginLbl: UILabel!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var memberImageView: UIImageView!
    
    @IBOutlet weak var memberNameLbl: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var facebookImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentMember = GroupMembers.currentMemmber
        
        setLayoutShadow()
        setMemberDetails()
        // Do any additional setup after loading the view.
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
        if currentMember?.path != nil {
           memberImageView.layer.borderWidth = 0
            memberImageView.layer.masksToBounds = false
            memberImageView.layer.cornerRadius = memberImageView.frame.height/2
            memberImageView.clipsToBounds = true
            var urlString = ApiRouts.Web + (currentMember?.path)!
            print(urlString)
            if currentMember?.path?.contains("https") == true {
                print("in IF ")
                urlString =  (currentMember?.path)!
            }
            let url = URL(string: urlString)
            
           memberImageView.downloadedFrom(url: url!)
        }
        
    }

   
    @IBAction func onCloseTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
