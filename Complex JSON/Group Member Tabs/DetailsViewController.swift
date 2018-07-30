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
import Kingfisher

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
   
    @IBOutlet var groupLeaderView: UIView!
    var images2: [InputSource] = []
    @IBOutlet var joinView: UIView!
    @IBOutlet var leftToJoinLbl: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinView.layer.borderColor = Colors.PrimaryColor.cgColor
        joinView.layer.borderWidth = 1
        /*
         self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
         self.tabBarController?.tabBar.items![1].title = "Joined"
 */
        //member
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
        }
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
        slideShow.isMultipleTouchEnabled = false
        slideShow.contentScaleMode = .scaleAspectFill
        
        slideShow.pageControlPosition = .insideScrollView
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        groupRequest.getGroupImages(id:( singleGroup?.id)!){ (output) in
            self.groupImages = output! as [GroupImage]
                print("%%% \(self.groupImages.count)")
            if self.groupImages.count == 0 {
                self.slideShow.setImageInputs([
                    ImageSource(image: UIImage(named: "Group Placeholder")!)])
            }else {
                
                var image_path: String = ""
                for image in self.groupImages {
                    if image.path !=  nil {
                        image_path = "\(ApiRouts.Media)\(image.path!)"
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
            self.leftToJoinLbl.text = "Closed"
        }
        else{
            self.leftToJoinLbl.text = "\(days) d' \(hours) h' to join"
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
            companyLbl.text = (singleGroup?.group_leader_company_name!)!
            
        }
        else{
            companyLbl.isHidden = true
            
        }
        
    }
    func setTripTimeDuration(startDate: String, endDate: String){
        let startMonth: String = self.getMonthName(month: startDate[5...6])
        let endMonth: String = self.getMonthName(month: endDate[5...6])
        let startDay: String = startDate[8...9]
        let endDay: String = endDate[8...9]
        if startMonth == endMonth {
            if startDay == endDay{
                tripDurationLbl.text = "One day"
            }
            else{
              //  tripDurationLbl.text = startDay+" "+startMonth + "-" + endDay+" "+endMonth
                tripDurationLbl.text = startDay+"-" + endDay+" "+endMonth

            }
            

        }else{
            tripDurationLbl.text = startDay+"'"+startMonth + " - " + endDay+"'"+endMonth
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
