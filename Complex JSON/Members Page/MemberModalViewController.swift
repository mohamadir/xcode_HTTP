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

class MemberModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentMember: GroupMember?
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var companionView: UIView!
    @IBOutlet weak var memberRoleLbl: UILabel!
    @IBOutlet weak var memberOriginLbl: UILabel!
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var pairText: UILabel!
    @IBOutlet weak var pairIcon: UIImageView!
    @IBOutlet weak var pairView: UIView!
    @IBOutlet weak var memberNameLbl: UILabel!
    @IBOutlet weak var chatIcon: UIButton!
    @IBOutlet weak var companionsTableView: UITableView!
    var editMmeber: Bool = false
    var companionsHttp: CompanionsRequset?
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
        let VerifyAlert = UIAlertController(title: "Pair with \((GroupMembers.currentMemmber?.first_name) != nil ? (GroupMembers.currentMemmber?.first_name)! : "") \((GroupMembers.currentMemmber?.last_name) != nil ? (GroupMembers.currentMemmber?.last_name)! : "")", message: "Pairing allows you to request from the group leader to relate to you and your paired friend as a couple or group. For example to share a room, to sit next to each other during meals or trips, etc.", preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Request Pairung", comment: "Default action"), style: .`default`, handler: { _ in
            
            self.sendPair()
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
     
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    fileprivate func cancelPair() {
        let VerifyAlert = UIAlertController(title: "Pair with \((GroupMembers.currentMemmber?.first_name) != nil ? (GroupMembers.currentMemmber?.first_name)! : "") \((GroupMembers.currentMemmber?.last_name) != nil ? (GroupMembers.currentMemmber?.last_name)! : "")", message: "Would you like to cancel the pairing with this member?" + "\nIf you already sent a paring request, it will be canceled", preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel pairing", comment: "Default action"), style: .`default`, handler: { _ in
            self.removePair()
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Stay paired", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
            
            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        //refreshCompanions
        SwiftEventBus.onMainThread(self, name: "refreshCompanions") { result in
            self.getCompanions()
            SwiftEventBus.post("refreshMembers")
        }
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        companionsTableView.delegate = self
        companionsTableView.dataSource = self
        let defaults = UserDefaults.standard
        companionsTableView.separatorStyle = .none

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
        if (GroupMembers.currentMemmber?.id)! == (MyVriables.currentMember?.id)!{
            getCompanions()
        }
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
        if ((GroupMembers.currentMemmber?.status) != nil){
            if (GroupMembers.currentMemmber?.status)! == "nil"
            {
                self.pairView.isHidden = true
            }
        }
        setLayoutShadow()
        setMemberDetails()
        // Do any additional setup after loading the view.
    }
    @IBAction func chatClick(_ sender: Any) {
        
        isChatId = false
        var ProfileImage: String = ""
        if (self.currentMember?.profile_image) != nil {
            ProfileImage = (self.currentMember?.profile_image!)!
        }
        print("profile_image: \(ProfileImage)")
        
        ChatUser.currentUser = Partner(id: (self.currentMember?.id)!, email: (self.currentMember?.email) != nil ? (self.currentMember?.email)! : "", profile_image: ProfileImage , first_name: (self.currentMember?.first_name) != nil ? (self.currentMember?.first_name)! : "User \((self.currentMember?.id)!)" , last_name: (self.currentMember?.last_name) != nil ? (self.currentMember?.last_name)! : "")
         dismiss(animated: true, completion: {
             SwiftEventBus.post("GoToPrivateChat")
         })
       

       
        
    }
   
    func setLayoutShadow(){
        memberView.layer.shadowColor = UIColor.black.cgColor
        memberView.layer.shadowOpacity = 0.5
        memberView.layer.shadowOffset = CGSize.zero
        memberView.layer.shadowRadius = 4
        
    }
    
    func setMemberDetails(){
        //print((self.currentMember?.first_name!)! + " " + (currentMember?.last_name!)!)
        if self.currentMember?.first_name != nil && self.currentMember?.last_name != nil {
        memberNameLbl.text = (self.currentMember?.first_name!)! + " " + (currentMember?.last_name!)!
        }
        self.memberRoleLbl.text = currentMember?.role!
        if currentMember?.role != nil {
        if currentMember?.role! == "group_leader" {
            self.memberRoleLbl.text = "Group Leader"
        }
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
        else {
            memberImageView.image = UIImage(named: "default member 2")
        }
        memberImageView.contentMode = .scaleAspectFill
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func sendPair(){
        print("Url send Pair is " + ApiRouts.Api+"/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)")
        HTTP.POST(ApiRouts.Api+"/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)", parameters: []) { response in
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
    func getCompanions(){
        // TODO
        //self.companionsHttp = []
        
        HTTP.GET(ApiRouts.Api+"/members/\((MyVriables.currentMember?.id)!)/group/\((MyVriables.currentGroup?.id)!)/companions", parameters: ["hello": "world", "param2": "value2"]) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            do{

                self.companionsHttp = try JSONDecoder().decode(CompanionsRequset.self, from: response.data)
                DispatchQueue.main.sync {

                    if self.companionsHttp?.campanions != nil && self.companionsHttp?.campanions?.count != 0{
                        self.companionView.isHidden = false
                        self.companionsTableView.reloadData()
                    }
                    else
                    {
                        self.companionsTableView.reloadData()
                        self.companionView.isHidden = true
                    }
                    
                }

            }
            catch let error {

            }
            
        }
    }
    
    
    func removePair(){
        print("Url send Pair is " + ApiRouts.Web+"/api/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)")
        HTTP.DELETE(ApiRouts.Api+"/pairs?sender_id=\((MyVriables.currentMember?.id)!)&receiver_id=\((GroupMembers.currentMemmber?.id)!)&group_id=\((MyVriables.currentGroup?.id)!)", parameters: []) { response in
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companionsHttp?.campanions != nil ? (self.companionsHttp?.campanions?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanionCell", for: indexPath) as! CompanionCell
        cell.selectionStyle = .none
        cell.birthDate.text = self.companionsHttp?.campanions![indexPath.row].birth_date != nil ? (self.companionsHttp?.campanions![indexPath.row].birth_date)! : ""
        cell.fullName.text = ((self.companionsHttp?.campanions![indexPath.row].first_name != nil) && (self.companionsHttp?.campanions![indexPath.row].last_name != nil)) ? "\((self.companionsHttp?.campanions![indexPath.row].first_name)!) \((self.companionsHttp?.campanions![indexPath.row].last_name)!)"  : ""
        
        cell.edit.tag = indexPath.row
        cell.edit.addTarget(self, action: #selector(self.editCompanion(_:)), for: .touchUpInside)
        cell.remove.tag = indexPath.row
        cell.remove.addTarget(self, action: #selector(self.removeCompanion(_:)), for: .touchUpInside)

        return cell
        
    }
    @objc func editCompanion(_ sender: UIButton){ //<- needs `@objc`
        print("edit \(sender.tag)")
        MyVriables.currentComapnion = CompanionInfo(first_name: (self.companionsHttp?.campanions![sender.tag].first_name != nil ? (self.companionsHttp?.campanions![sender.tag].first_name)! : ""), last_name: (self.companionsHttp?.campanions![sender.tag].last_name != nil ? (self.companionsHttp?.campanions![sender.tag].last_name)! : ""), group_id: (MyVriables.currentGroup?.id)!, gender: "male", birth_date: (self.companionsHttp?.campanions![sender.tag].birth_date != nil ? self.companionsHttp?.campanions![sender.tag].birth_date! : ""), id: (self.companionsHttp?.campanions![sender.tag].id)!)
        MyVriables.currentIndexCompanion = -1
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editCompanion") as! EditCompanionModal
        self.present(vc, animated: true, completion: nil)

    }
    @objc func removeCompanion(_ sender: UIButton){ //<- needs `@objc`
        let VerifyAlert = UIAlertController(title: "Are uou sure to remove companion ?", message: nil, preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            let url = ApiRouts.Api+"/members/companions/\((self.companionsHttp?.campanions?[sender.tag].id)!)"
            HTTP.DELETE(url, parameters: []) { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                do{
                    DispatchQueue.main.sync {
                        SwiftEventBus.post("refreshCompanions")

               }
                }
                catch let error {
                }
            }
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
            
            
        }))
        self.present(VerifyAlert, animated: true) {
            VerifyAlert.view.superview?.isUserInteractionEnabled = true
            VerifyAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
}
