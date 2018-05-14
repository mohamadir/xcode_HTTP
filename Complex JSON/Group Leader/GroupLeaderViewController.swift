//
//  GroupLeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
class GroupLeaderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    @IBOutlet weak var scrollView: UIScrollView!
    // hi hi
    //bye bye
    @IBOutlet weak var ratingTbaleview: UITableView!
    @IBOutlet weak var leaderImageview: UIImageView!
    var singleGroup: TourGroup?
    @IBOutlet weak var leadeAboutLbl: UILabel!
    @IBOutlet weak var activeGroupLbl: UILabel!
    @IBOutlet weak var leaderEmailLbl: UILabel!
    @IBOutlet weak var leaderGenderLbl: UILabel!
    @IBOutlet weak var leaderBiryhdayLbl: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var leaderNameLbl: UILabel!
    var count: Int = 2
    
    @IBOutlet weak var tableViewHeightConstrans: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.singleGroup  = MyVriables.currentGroup!
        ratingTbaleview.delegate = self
        ratingTbaleview.dataSource = self
        ratingTbaleview.isScrollEnabled = false
       ratingTbaleview.separatorStyle = .none
        
        ratingTbaleview.allowsSelection = false 
        groupNameLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : "There is no group name"
        activeGroupLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : ""
        leadeAboutLbl.text = singleGroup?.group_leader_about != nil ? singleGroup?.group_leader_about : "There no description right now"
        leaderEmailLbl.text = singleGroup?.group_leader_email != nil ? singleGroup?.group_leader_email : "There is no email"
        leaderGenderLbl.text = singleGroup?.group_leader_gender != nil ? singleGroup?.group_leader_gender : "There is no gender"
        leaderBiryhdayLbl.text = singleGroup?.group_leader_birth_date != nil ? singleGroup?.group_leader_birth_date : "There is no Birthday"
        leaderNameLbl.text = singleGroup?.group_leader_first_name != nil ? singleGroup?.group_leader_first_name : ""
        do{
            if singleGroup?.group_leader_image != nil{
                var urlString = try ApiRouts.Web + (singleGroup?.group_leader_image)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                var url = URL(string: urlString)
                leaderImageview.sd_setImage(with: url!, completed: nil)
            }
        }catch let error {
            print(error)
        }
        
        ratingTbaleview.reloadData()
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if count == 1 {
            var height: CGFloat = 0
            for cell in tableView.visibleCells {
                height += cell.bounds.height
            }
            
            tableViewHeightConstrans.constant = height
              print("height is --- \(height)")
        return 1
        }
        else
        {
            if count == 0 {
               
                tableViewHeightConstrans.constant = 0
                 return 0
            }
            else {
            
            var height: CGFloat = 0
            for cell in tableView.visibleCells {
                height += cell.bounds.height
            }
            tableViewHeightConstrans.constant = height
            print("height is --- \(height)")
                return 2
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        cell.selectionStyle = .none
        if count == 1 {
            var height: CGFloat = 0
            for cell in tableView.visibleCells {
                height += cell.bounds.height
            }
            
            tableViewHeightConstrans.constant = height
            print("height is --- \(height)")

        }
        else
        {
            if count == 0 {
                
                tableViewHeightConstrans.constant = 0
  
            }
            else {
                
                var height: CGFloat = 0
                for cell in tableView.visibleCells {
                    height += cell.bounds.height
                }
                tableViewHeightConstrans.constant = height
                print("height is --- \(height)")

            }
            
        }
        return cell
    }
    @IBAction func showAddReview(_ sender: Any) {
        //showAddReview
        performSegue(withIdentifier: "showAddReview", sender: self)

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}

