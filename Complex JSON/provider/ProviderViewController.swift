//
//  ProviderViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 26.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import ImageSlideshow
import SwiftEventBus
import ARSLineProgress

class ProviderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableViewHeightConstrans: NSLayoutConstraint!
    @IBOutlet weak var tableViewRatings: UITableView!
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var rating: UILabel!
    var count: Int = 0
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var allReviewLbl: UIButton!
    var urlGetService: String?
    var urlGetRate: String?
    var ratingsArray: [RatingModel]?
    @IBAction func addReviewClick(_ sender: Any) {
       
        if  (MyVriables.currentMember?.gdpr?.rating_reviews)! == true {
        performSegue(withIdentifier: "showAddReview", sender: self)
        }else
        {
            var gdprObkectas : GdprObject = GdprObject(title: "Rating a& reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: (MyVriables.currentMember?.gdpr?.rating_reviews) != nil ? (MyVriables.currentMember?.gdpr?.rating_reviews)! : false, parmter: "rating_reviews", image: "In order to write a review, please approve the review save and usage:")
            MyVriables.enableGdpr = gdprObkectas
            performSegue(withIdentifier: "showEnable", sender: self)
        }
        
        
    }
    var providerModel : ProviderModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "refresh-rating_reviews") { result in
            self.performSegue(withIdentifier: "showAddReview", sender: self)
        }
        tableViewRatings.delegate = self
        tableViewRatings.dataSource = self
        tableViewRatings.isScrollEnabled = false
        tableViewRatings.separatorStyle = .none
        slideShow.circular = false
        slideShow.zoomEnabled = true
        slideShow.isMultipleTouchEnabled = false
        slideShow.pageControlPosition = .insideScrollView
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        tableViewRatings.reloadData()
        SwiftEventBus.onMainThread(self, name: "newComment") { result in
        self.getRatings()
        }


    }
    override func viewDidAppear(_ animated: Bool) {
        getUrlService()

    }
    override func viewWillAppear(_ animated: Bool) {
        print("after dismniss ")
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        do
        {
            dismiss(animated: true, completion: nil)
            
        }
        catch let error {
            print(error)
        }
    }

    @IBAction func allReviewClick(_ sender: Any) {
        performSegue(withIdentifier: "showAllReview", sender: self)
            ProviderInfo.nameProvider = fullName.text!
            ProviderInfo.urlRatings = urlGetRate!
    }
    func getUrlService(){
        switch ProviderInfo.currentProviderName!{
        case "Hotels":
            urlGetService = ApiRouts.Api+"/get/hotel/\((ProviderInfo.currentProviderId)!)"
            urlGetRate = ApiRouts.Api+"/getratings/hotels/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "hotels"
        case "Places":
            urlGetService = ApiRouts.Api+"/get/place/\((ProviderInfo.currentProviderId)!)"
             urlGetRate = ApiRouts.Api+"/getratings/places/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "places"
        case "Restaurants":
            urlGetService = ApiRouts.Api+"/get/restaurant/\((ProviderInfo.currentProviderId)!)"
             urlGetRate = ApiRouts.Api+"/getratings/restaurants/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "restaurants"
        case "Tourguides":
            urlGetService = ApiRouts.Api+"/get/tourguide/\((ProviderInfo.currentProviderId)!)"
             urlGetRate = ApiRouts.Api+"/getratings/tourguides/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "tourguides"
        case "Transport":
            urlGetService = ApiRouts.Api+"/get/transport/\((ProviderInfo.currentProviderId)!)"
             urlGetRate = ApiRouts.Api+"/getratings/transports/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "transports"
        case "Activities":
            urlGetService = ApiRouts.Api+"/get/activity/\((ProviderInfo.currentProviderId)!)"
             urlGetRate = ApiRouts.Api+"/getratings/activities/\((ProviderInfo.currentProviderId)!)"
            ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
            ProviderInfo.model_type = "activities"
        default:
            urlGetService = "null"
             urlGetRate = "null"
        }
        getProvider()
        getRatings()
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
                for cell in self.tableViewRatings.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            else
            {
                var height: CGFloat = 0
                for cell in self.tableViewRatings.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            
        }
    }
    
    func getRatings() {
        
//        ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
//        ProviderInfo.model_type = "activities"
        HTTP.GET(urlGetRate!, parameters:[])
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
                        self.tableViewRatings.reloadData()
                    }
                    else
                    {
                        if self.ratingsArray?.count == 1 {
                            self.count = 1
                            self.tableViewRatings.reloadData()
                            
                        }
                        else
                        {
                            self.count = 2
                            self.tableViewRatings.reloadData()
                            
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
    func getProvider(){
        
        print("^^^^ "+urlGetService!)
        HTTP.GET(urlGetService!, parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
       
            
          
             do{
                
                self.providerModel = try JSONDecoder().decode(ProviderModel.self, from: response.data)
                DispatchQueue.main.sync {
                 ///  print("!!!!!!!!!!!!!! \(self.providerModel?.translations![0].)")
                    if self.providerModel?.images != nil {
                          print("%%%%%%%%%%%%%%%%%%%% \(self.providerModel?.images?.count)")
                        if self.providerModel?.images?.count == 0 {
                        
                            self.slideShow.setImageInputs([
                                ImageSource(image: UIImage(named: "Group Placeholder")!)])
                        }
                        else{
                             print("%%%%%%%%%%%%%%%%%%%% \(self.providerModel?.images!)")
                            var images2: [InputSource] = []
                            
                            
                            for image in (self.providerModel?.images)! {
                                if image.path !=  nil {
                                    let image_path: String = "\(ApiRouts.Media)\(image.path!)"
                                    print("%%%%%%%%%%%%%%%%%%%% \(image_path)")
                                    if AlamofireSource(urlString: image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) != nil  {
                                        print("1details image paths : \(image_path) and  ok !!!")
                                       
                                        images2.append(AlamofireSource(urlString: image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)            
                                    }
                                }
                                
                            }
                            print("after print \(images2.count)")
                            //self.slideShow.setImageInputs(images2)
                            self.slideShow.setImageInputs(images2)
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProviderViewController.didTap))
                            self.slideShow.addGestureRecognizer(gestureRecognizer)
                            
                        }
                    }
                    if self.providerModel?.description != nil
                    {
                        self.about.text = (self.providerModel?.description)!
                        
                    }
                    else
                    {
                        if self.providerModel?.bio != nil
                        {
                            self.about.text = (self.providerModel?.bio)!
                        }
                        else
                        {
                             self.about.text = "there is no info"
                        }
                        
                    }
                    if self.providerModel?.rating != nil {
                        self.rating.text = "\((self.providerModel?.rating)!) out of 10"
                        ProviderInfo.ratings = "\((self.providerModel?.rating)!) out of 10"
                    }
                    if self.providerModel?.company_name != nil
                    {
                        self.fullName.text = (self.providerModel?.company_name)!
                    }
                    else
                    {
                        if self.providerModel?.name != nil
                        {
                          
                             self.fullName.text = (self.providerModel?.name)!
                        }
                        else
                        {
                            if self.providerModel?.first_name != nil && self.providerModel?.last_name != nil
                            {
                                self.fullName.text = "\((self.providerModel?.first_name)!) \((self.providerModel?.last_name)!)"
                               
                            }
                        
                        }
                        
                    }
                     self.location.text =  ( self.providerModel?.city != nil ? self.providerModel?.city : "there is not exits")!
                    if self.providerModel?.phone != nil
                    {
                         self.phoneNumber.text = self.providerModel?.phone
                    }
                    else{
                        self.phoneNumber.text = "there no phone number"
                        self.phoneNumber.alpha = 0.3

                    }
                    
                    
                    if  self.providerModel?.phone != nil
                    {
                          self.phoneNumber.text = (self.providerModel?.phone)!
                    }
                    else
                    {
                        self.phoneNumber.text = "there no phone number"

                    }
                    if  self.providerModel?.contacts != nil
                    {
                        if  (self.providerModel?.contacts?.count)! > 0
                        {
                            if (self.providerModel?.contacts![0].email) == nil
                            {
                                self.email.text = "no email"
                                self.email.alpha = 0.3
                            }
                            else{
                             self.email.text =  (self.providerModel?.contacts![0].email)
                            }
                        }
                        else
                        {
                             self.email.text = "no email"
                            self.email.alpha = 0.3
                        }
                    }
                    else
                    {
                        self.email.text = "no email"
                        self.email.alpha = 0.3
                    }
                    if self.providerModel?.webSite != nil
                    {
                        self.website.text = (self.providerModel?.webSite)
                    }
                    else{
                        self.website.text = "there is no website"
                        self.website.alpha = 0.3
                    }
                    
                   

                }

                
                print("after Decoding \(self.providerModel)")
            }
             catch let error {
            }
      }
            
    }
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
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
                var urlString: String = try ApiRouts.Media + (self.ratingsArray?[indexPath.row].image_path)!
                 urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default user"), completed: nil)
                    
                }
            }
            if self.ratingsArray?[indexPath.row].reviewer_id! == MyVriables.currentMember?.id! {
                cell.removeRate.isHidden = false
            }
            else {
                cell.removeRate.isHidden = true
            }
            cell.removeRate.tag = (self.ratingsArray?[indexPath.row].id)!
            cell.removeRate.addTarget(self,action:#selector(buttonClicked),for:.touchUpInside)
        }
        
        return cell
    }
    @objc func buttonClicked(sender:UIButton)
    {
        let VerifyAlert = UIAlertController(title: "Verify", message: "Are you sure you want to remove this rate ?", preferredStyle: .alert)
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            self.removeRate(reviwerId : sender.tag)
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    func removeRate(reviwerId : Int) {
        
        //print(ApiRouts.Api+"/ratings/\((reviwerId))")
        ARSLineProgress.show()
        HTTP.DELETE(ApiRouts.Api+"/ratings/\((reviwerId))", parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                ARSLineProgress.hide()
                
                return //also notify app of failure as needed
            }
            do {
                
                print("removed is \(response.description)")
                
                DispatchQueue.main.sync {
                    ARSLineProgress.hide()
                    self.getRatings()
                }
            }
            catch {
                
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentMemmber: GroupMember? = GroupMember(id : self.ratingsArray?[indexPath.row].reviewer_id!, email : "", first_name : self.ratingsArray?[indexPath.row].first_name != nil ? self.ratingsArray?[indexPath.row].first_name! : "", last_name : self.ratingsArray?[indexPath.row].last_name != nil ? self.ratingsArray?[indexPath.row].last_name! : "", profile_image : self.ratingsArray?[indexPath.row].image_path != nil ? self.ratingsArray?[indexPath.row].image_path! : nil,companion_number : 0, status : "nil", role : "member")
        GroupMembers.currentMemmber = currentMemmber
        performSegue(withIdentifier: "showMember", sender: self)
       
    }
  
}

