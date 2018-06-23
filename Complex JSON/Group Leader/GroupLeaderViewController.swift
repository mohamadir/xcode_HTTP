//
//  GroupLeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftHTTP
import SwiftEventBus
class GroupLeaderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   

    @IBOutlet weak var allReviewLbl: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
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
    var ratingsArray: [RatingModel]?
    @IBOutlet weak var tableViewHeightConstrans: NSLayoutConstraint!
    
    
    @IBAction func allReviewClick(_ sender: Any) {
        performSegue(withIdentifier: "showAllReview", sender: self)
        ProviderInfo.nameProvider = leaderNameLbl.text!
        ProviderInfo.urlRatings = "https://api.snapgroup.co.il/api/getratings/members/\((MyVriables.currentGroup?.group_leader_id)!)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "newComment") { result in
            self.getRatings()
        }
       // print("Refresh is \((MyVriables.enableGdpr?.parmter)!)")
        SwiftEventBus.onMainThread(self, name: "refresh-rating_reviews") { result in
            ProviderInfo.model_type = "members"
            ProviderInfo.model_id =  (MyVriables.currentGroup?.group_leader_id) != nil ? (MyVriables.currentGroup?.group_leader_id)! : -1
            self.performSegue(withIdentifier: "showAddReview", sender: self)
        }
        //"refresh\((MyVriables.enableGdpr?.parmter)!)"
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
    override func viewWillAppear(_ animated: Bool) {
        getRatings()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ratingsArray?.count == 0 {
            tableViewHeightConstrans.constant = 0
            return 0
        }
        else
        {
            if self.ratingsArray?.count == 1 {
                return 1
                
            }
            else
            {
                return 2
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        cell.selectionStyle = .none
        if self.ratingsArray != nil {
            cell.fullNameLbl.text = "\((self.ratingsArray?[indexPath.row].first_name)!) \((self.ratingsArray?[indexPath.row].last_name)!)"
            cell.reviewLbl.text = "\((self.ratingsArray?[indexPath.row].review)!) "
            cell.ratingNumber.text = "\((self.ratingsArray?[indexPath.row].rating)!) out of 10"
            
            
            if self.ratingsArray?[indexPath.row].image_path != nil
            {
                var urlString: String = try ApiRouts.Web + (self.ratingsArray?[indexPath.row].image_path)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default user"), completed: nil)
                    
                }
            }
        }
        
        return cell
    }
    @IBAction func showAddReview(_ sender: Any) {
        //showAddReview
        if  (MyVriables.currentMember?.gdpr?.rating_reviews)! == true {
       ProviderInfo.model_type = "members"
       ProviderInfo.model_id =  (MyVriables.currentGroup?.group_leader_id)!
        performSegue(withIdentifier: "showAddReview", sender: self)
        }else
        {
            var gdprObkectas : GdprObject = GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: (MyVriables.currentMember?.gdpr?.rating_reviews) != nil ? (MyVriables.currentMember?.gdpr?.rating_reviews)! : false, parmter: "rating_reviews", image: "In order to write a review, please approve the review save and usage:")
            MyVriables.enableGdpr = gdprObkectas
            performSegue(withIdentifier: "showEnableModal", sender: self)
            
        }

    }
    func getRatings() {
        
        //        ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
        //        ProviderInfo.model_type = "activities"
        HTTP.GET("https://api.snapgroup.co.il/api/getratings/members/\((MyVriables.currentGroup?.group_leader_id)!)", parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                self.ratingsArray = try JSONDecoder().decode([RatingModel].self, from: response.data)
                print("The Array is \(self.ratingsArray!)")
                DispatchQueue.main.sync {
                    if self.ratingsArray?.count == 0 {
                        self.count = 0
                        self.ratingTbaleview.reloadData()
                    }
                    else
                    {
                        if self.ratingsArray?.count == 1 {
                            self.count = 1
                            self.ratingTbaleview.reloadData()
                            
                        }
                        else
                        {
                            self.count = 2
                            self.ratingTbaleview.reloadData()
                            
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.setTableViewHeigh()
                    }
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    fileprivate func setTableViewHeigh() {
        if self.ratingsArray?.count == 0 {
            self.tableViewHeightConstrans.constant = 0
            self.allReviewLbl.isHidden = true
        }
        else
        {
            self.allReviewLbl.isHidden = false
            if self.ratingsArray?.count == 1 {
                var height: CGFloat = 0
                for cell in self.ratingTbaleview.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            else
            {
                var height: CGFloat = 0
                for cell in self.ratingTbaleview.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            
        }
    }
    
    
}

