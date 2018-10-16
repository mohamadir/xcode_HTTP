//
//  DetailsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/25/18.
//  Copyright © 2018 snapmac. All rights reserved.
//
import UIKit
import Auk
import ImageSlideshow
import SwiftHTTP
import SwiftEventBus
import Scrollable
import ARSLineProgress


extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
class DetailsViewController: UIViewController {
   
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bookNowView: UIView!
    @IBOutlet var groupLeaderView: UIView!
    @IBOutlet weak var tagLineConstrate: NSLayoutConstraint!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var tagLineView: UIView!
    var images2: [InputSource] = []
    @IBOutlet var joinView: UIView!
    @IBOutlet var leftToJoinLbl: UILabel!
    @IBOutlet weak var tagLineLbl: UILabel!
    @IBOutlet weak var priceWithSale: UIView!
    
    let cvv: ViewController  = ViewController()
     var groupImages: [GroupImage] = []
    @IBOutlet var scrollView: UIScrollView!
    var singleGroup: TourGroup?
    

    @IBOutlet var groupAppView: UIView!
    @IBOutlet var slideShow: ImageSlideshow!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var showMoreButton: UIButton!
    var isCollapsed: Bool = false
    
    
    @IBOutlet weak var filterTwo: UIView!
    @IBOutlet weak var filterThree: UIView!
    @IBOutlet weak var filterOne: UIView!
    @IBOutlet weak var pricesView: UIView!
    @IBOutlet var member_status_view: UIView!
    @IBOutlet var member_status_lbl: UILabel!
    @IBOutlet var member_Status_Im: UIImageView!
    @IBOutlet var groupLeaderImageView: UIImageView!
    
    @IBOutlet var companyLbl: UILabel!
    @IBOutlet var groupLeaderNameLbl: UILabel!
    @IBOutlet var tripDurationLbl: UILabel!
  
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var groupTitleLb: UILabel!
    
    fileprivate func getGroupImages() -> HTTP? {
        return HTTP.GET("\(ApiRouts.Api)/groups/\((MyVriables.currentGroup?.id)!)/images", parameters: []) { response in
            if response.error != nil {
                print("error \(response.error?.localizedDescription)")
                return
            }
            do {
                let images = try JSONDecoder().decode([GroupImage].self, from: response.data)
                print ("successed")
                DispatchQueue.main.sync {
                    self.groupImages = images
                    if self.groupImages.count == 0 {
                        self.slideShow.setImageInputs([
                            ImageSource(image: UIImage(named: "Group Placeholder")!)])
                    }else {
                        
                        var image_path: String = ""
                        for image in self.groupImages {
                            if image.path !=  nil {
                                
                                image_path = "\(ApiRouts.Media)\(image.path!)"
                                image_path = image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                                print("Image payjso \(image_path)")
                                if AlamofireSource(urlString: image_path) != nil  {
                                    self.images2.append(AlamofireSource(urlString: image_path)!)
                                }
                            }
                        }
                        self.slideShow.contentScaleMode = .scaleAspectFill
                        self.slideShow.contentMode = .scaleAspectFill
                        self.slideShow.setImageInputs(self.images2)
                    }
                }
            }
            catch{
                
            }
            //do things...
        }
    }
    @IBAction func moreInfoClick(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    fileprivate func bookNowFunc() {
        if MyVriables.currentGroup?.role != nil &&  (MyVriables.currentGroup?.role)! != "observer"
        {
            MyVriables.isBookClick = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
            self.navigationController?.pushViewController(vc,animated: true)
            
        }else{
            MyVriables.isBookClick = true
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    @IBAction func bookNowClick(_ sender: Any) {
         setCheckTrue(type: "book_now", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    @IBAction func availbleDateClick(_ sender: Any) {
        setCheckTrue(type: "available_dates", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        joinView.layer.borderColor = Colors.PrimaryColor.cgColor
        joinView.layer.borderWidth = 1
        ARSLineProgress.hide()

        //member
        if MyVriables.currentGroup!.special_price_tagline != nil {
            self.tagLineView.isHidden = false
            self.tagLineLbl.text = "\((MyVriables.currentGroup!.special_price_tagline)!)"
           // self.tagLineConstrate.constant = 90
            
        }else
        {
            //self.tagLineConstrate.constant = 60
             self.tagLineView.isHidden = true
        }
        
        //member
        if MyVriables.currentGroup!.price != nil {
            pricesView.isHidden = false
            self.price.text = "£\((MyVriables.currentGroup!.price)!)"
        }else
        {
            pricesView.isHidden = true
            self.price.text = ""
        }
        if MyVriables.currentGroup!.special_price != nil {
            
            if MyVriables.currentGroup!.price != nil {
                pricesView.isHidden = true
                priceWithSale.isHidden = false
                oldPrice.text = "£\((MyVriables.currentGroup!.price)!)"
                newPrice.text = "£\((MyVriables.currentGroup!.special_price)!)"
            }else {
                priceWithSale.isHidden = true
                pricesView.isHidden = false
            self.price.text = "£\((MyVriables.currentGroup!.special_price)!)"
         
            
            }
        }else
        {
            priceWithSale.isHidden = true
            
        }
        if (MyVriables.currentGroup?.group_tools?.payments!)! == false
        {
            self.groupAppView.isHidden = false
            self.filterTwo.isHidden = true
            self.filterThree.isHidden = true
        }else{
            if (MyVriables.currentGroup?.rotation) != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
                self.groupAppView.isHidden = true
                self.filterTwo.isHidden = true
                self.filterThree.isHidden = false
            }else{
                self.groupAppView.isHidden = true
                self.filterTwo.isHidden = false
                self.filterThree.isHidden = true
            }
           // self.bookNowView.isHidden = false
        }
        SwiftEventBus.onMainThread(self, name: "roleChanges") { result in
            self.member_status_lbl.text = self.tabBarController?.tabBar.items![1].title
            self.member_Status_Im.image = self.tabBarController?.tabBar.items![1].image
        }
        member_status_lbl.text = self.tabBarController?.tabBar.items![1].title
        member_Status_Im.image = self.tabBarController?.tabBar.items![1].image
        if (self.tabBarController?.tabBar.items![1].title?.lowercased().contains("closed"))!{
            member_status_view.backgroundColor = UIColor.clear
            
        }
        groupLeaderView.addTapGestureRecognizer {
          self.performSegue(withIdentifier: "showGroupLeader", sender: self)
        }
        member_status_view.addTapGestureRecognizer {
            setCheckTrue(type: "interested", groupID: (MyVriables.currentGroup?.id)!)
            self.tabBarController?.selectedIndex = 1
        }
        groupAppView.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 2
        }
        self.singleGroup  = MyVriables.currentGroup!
        let groupRequest = Main()
//        titleLabel.text = singleGroup?.title
        if singleGroup?.translations?.count != 0 {
             groupTitleLb.text = singleGroup?.translations?[0].title
            descriptionLbl.text = singleGroup?.translations?[0].description

        }else{
            if singleGroup?.title != nil {
              groupTitleLb.text = singleGroup?.title
            }
            if singleGroup?.description != nil {
                groupTitleLb.text = singleGroup?.description
            }
        }

        setGroupLeader()

        setTripTimeDuration(startDate: (singleGroup?.start_date)!, endDate: (singleGroup?.end_date)!)
        self.descriptionLbl.numberOfLines = 3
        
       
        if singleGroup?.registration_end_date != nil{
            calculateRegisterDate(date: (singleGroup?.registration_end_date)!)
        }else {
            calculateRegisterDate(date: (singleGroup?.start_date)!)
        }
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
        slideShow.isMultipleTouchEnabled = false
        slideShow.contentScaleMode = .scaleAspectFill
        
        slideShow.pageControlPosition = .insideScrollView
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        getGroupImages()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.slideShow.currentPageChanged = nil
    }
    @IBAction func ExpandDescriptionTapped(_ sender: Any) {
        if isCollapsed != true {
            self.descriptionLbl.numberOfLines = 0
            self.descriptionLbl.sizeToFit()
            showMoreButton.setTitle("Show Less", for: .normal )
            
        }
        else{
            self.descriptionLbl.numberOfLines = 3
            self.descriptionLbl.lineBreakMode = .byWordWrapping
            self.descriptionLbl.sizeToFit()
            showMoreButton.setTitle("Show More", for: .normal )


        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        
        isCollapsed = !isCollapsed
    }
    
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }
   


    func calculateRegisterDate(date: String){
        if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"
        {
            if MyVriables.currentGroup?.start_time != nil && MyVriables.currentGroup?.end_time != nil {
                self.tripDurationLbl.text = "\(setFormat(date: (MyVriables.currentGroup?.start_time)!)) - \(setFormat(date: (MyVriables.currentGroup?.end_time)!))"
            }else {
                self.tripDurationLbl.text = " "
            }
        }
        else{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("DDDAAATTEEE: "+formatter.string(from: currentDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatter.date(from: date)!
        print("REG END DATE: "+dateFormatter.string(from: date2))
        let days : Int = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day!
        let hours: Int = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour!
        print("days: \(days) , hours: \(hours)")
        if days < 0 || hours < 0 {
            self.tripDurationLbl.text = "Closed"
        }
        else{
            self.tripDurationLbl.text = "\(days) d' \(hours) h'"
        }
        }

    }
    func setGroupLeader(){
        self.groupLeaderNameLbl.text = "\((singleGroup?.group_leader_first_name!)!) \((singleGroup?.group_leader_last_name!)!)"
        groupLeaderImageView.layer.borderWidth = 0
        groupLeaderImageView.layer.masksToBounds = false
        groupLeaderImageView.layer.cornerRadius = groupLeaderImageView.frame.height/2
        groupLeaderImageView.clipsToBounds = true
     //   print(ApiRouts.Web + (singleGroup?.group_leader_image!)!)
       // print(singleGroup?.group_leader_image)
       
        if singleGroup?.group_leader_image != nil{
            var urlString: String = ApiRouts.Media + (singleGroup?.group_leader_image!)!
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: urlString)
            groupLeaderImageView.downloadedFrom(url: url!, contentMode: .scaleToFill)

        }
        if singleGroup?.is_company! != 0 {
            companyLbl.text = (singleGroup?.group_leader_company_name) != nil ? (singleGroup?.group_leader_company_name!)! : ""
            
        }
        else{
            companyLbl.isHidden = true
            
        }
        
    }
    func setTripTimeDuration(startDate: String, endDate: String){
        if (MyVriables.currentGroup?.rotation) != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
            
            
            leftToJoinLbl.text = MyVriables.currentGroup?.translations?[0].destination != nil ? (MyVriables.currentGroup?.translations?[0].destination)! : ""
        }
        else {
        let startMonth: String = self.getMonthName(month: startDate[5...6])
        let endMonth: String = self.getMonthName(month: endDate[5...6])
        let startDay: String = startDate[8...9]
        let endDay: String = endDate[8...9]
        if startMonth == endMonth {
            if startDay == endDay{
                leftToJoinLbl.text = "One day"
            }
            else{
              //  tripDurationLbl.text = startDay+" "+startMonth + "-" + endDay+" "+endMonth
                leftToJoinLbl.text = startDay+"-" + endDay+" "+endMonth

            }
            

        }else{
            leftToJoinLbl.text = startDay+"'"+startMonth + " - " + endDay+"'"+endMonth
        }
        }
    
    }
  
  func getMonthName(month: String) -> String{
    
        switch month {
            case "01":
                return "Jan"
            case "02":
                return "Feb"
            case "03":
                return "Mar"
            case "04":
                return "Apr"
            case "05":
                return "Jun"
            case "06":
                return "Jul"
            case "07":
                return "Aug"
            case "08":
                return "Sep"
            case "09":
                return "Oct"
            case "10":
                return "Nov"
            case "11":
                return "Dec"
            case "12":
                return "Feb"
            default:
                return "null"
            }
    }
  
}
