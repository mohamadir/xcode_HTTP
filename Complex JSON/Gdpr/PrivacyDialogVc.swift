//
//  PrivacyDialogVc.swift
//  Snapgroup
//
//  Created by snapmac on 28/10/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus

class PrivacyDialogVc: UIViewController {

    @IBOutlet weak var agreeBt: UIButton!
    @IBOutlet weak var termsClick: UILabel!
    @IBOutlet var allView: UIView!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var `switch`: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        overView.layer.cornerRadius = 10
        
        // border
        overView.layer.borderWidth = 1.0
        overView.layer.borderColor = UIColor.lightGray.cgColor
        
        // shadow
        overView.layer.shadowColor = UIColor.lightGray.cgColor
        overView.layer.shadowOffset = CGSize(width: 3, height: 3)
        overView.layer.shadowOpacity = 0.7
        overView.layer.shadowRadius = 4.0


       `switch`.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        termsClick.addTapGestureRecognizer {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SnapgroupTermModal") as! SnapgroupTermModal
            self.present(vc, animated: true, completion: nil)
            
        }
        `switch`.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        print("Siwtch is \(`switch`.isOn)")
        if `switch`.isOn == true {
            print("Siwtch Im inside true")
          //  self.agreeBt.isEnabled = true
            self.agreeBt.titleLabel?.textColor = Colors.PrimaryColor
        }else {
          //  self.agreeBt.isEnabled = false
            self.agreeBt.titleLabel?.textColor = UIColor.lightGray
        }
        
    }
    @IBAction func dismssAll(_ sender: Any) {
         self.dismiss(animated: true,completion: nil)
    }
    @IBAction func agerrClick(_ sender: Any) {
        if self.`switch`.isOn == true {

                setCheckTrue(type: "private_accept", groupID: -1)
            let gdpr : GdprPost = GdprPost(profile_details: true, phone_number: true, groups_relations: true, chat_messaging: true, pairing: true, real_time_location: true, files_upload: true, push_notifications: true, rating_reviews: true)
                MyVriables.arrayGdpr = gdpr
                self.dismiss(animated: true, completion: nil)
                if (MyVriables.fromGroup)! == "false"
                {
                    
                    if  MyVriables.facebookMember != nil {
                        SwiftEventBus.post("refreshGroups" , sender: MyVriables.facebookMember)
                        MyVriables.facebookMember = nil
                        
                    }else{
                        SwiftEventBus.post("refreshGroups")
                    }
                    MyVriables.joinToGroup = ""
                    return
                    
                }
                else
                {
                    if (MyVriables.fromGroup)! == "true"
                    {
                        if  MyVriables.facebookMember != nil {
                            SwiftEventBus.post("refreshFromGroup" , sender: MyVriables.facebookMember)
                            MyVriables.facebookMember = nil
                            
                        }else{
                            SwiftEventBus.post("refreshFromGroup")
                        }
                        
                        
                    }
                    else
                    {
                        if (MyVriables.fromGroup)! == "true-1"
                        {
                            if  MyVriables.facebookMember != nil {
                                SwiftEventBus.post("joinGroup" , sender: MyVriables.facebookMember)
                                MyVriables.facebookMember = nil
                                
                            }else{
                                SwiftEventBus.post("joinGroup")
                            }
                        }
                        else
                        {
                            if  MyVriables.facebookMember != nil {
                                SwiftEventBus.post("" , sender: MyVriables.facebookMember)
                                MyVriables.facebookMember = nil
                                
                            }else{
                                SwiftEventBus.post("refreshGroups")
                            }
                        }
                        
                    }
                }
            
            self.dismiss(animated: true, completion: nil)
                    setCheckTrue(type: "terms_accept", groupID: -1)
        }

    }
    @IBAction func disagreeClick(_ sender: Any) {
    }
    

}
