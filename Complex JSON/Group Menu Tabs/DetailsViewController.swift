//
//  DetailsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/25/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import Auk
import UserNotifications
import SocketIO
import ImageSlideshow
import SwiftHTTP
import Scrollable
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
   
    
    @IBOutlet weak var leftToJoinLbl: UILabel!
    
    @IBOutlet weak var groupLeaderView: UIView!
    let cvv: ViewController  = ViewController()
     var groupImages: [GroupImage] = []
    @IBOutlet weak var scrollView: UIScrollView!
    var singleGroup: TourGroup?
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    var isCollapsed: Bool = false
    
    
    @IBOutlet weak var groupLeaderImageView: UIImageView!
    
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var groupLeaderNameLbl: UILabel!
    @IBOutlet weak var tripDurationLbl: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Hide the navigation bar on the this view controller
     //   self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var groupTitleLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGroupDetails()
        self.singleGroup  = MyVriables.currentGroup!

        let groupRequest = Main()
        groupLeaderView.addTapGestureRecognizer {
            self.performSegue(withIdentifier:"leaderSegue", sender: self)
        }
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
        
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
        calculateRegisterDate(date: (singleGroup?.registration_end_date)!)
       // slideShow.draggingEnabled = false
        slideShow.isMultipleTouchEnabled = false
        slideShow.pageControlPosition = .insideScrollView
//        slideShow.pageControlPosition = .custom(padding: CGFloat(12))
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        groupRequest.getGroupImages(id:( singleGroup?.id)!){ (output) in
            self.groupImages = output!
            
                print("%%% \(self.groupImages.count)")
                var images2: [InputSource] = []
         //   print("group : \(self.singleGroup?.title!) images: \(self.groupImages)")

                  // var images2: [InputSource]?
                for image in self.groupImages {
                    if image.path !=  nil {
                    let image_path: String = "\(ApiRouts.Web)\(image.path!)"
                        print("details image paths : \(image_path)")
                    //print("%%%%%%%%%%%%%%%%%%%% \(image_path)")
                        if AlamofireSource(urlString: image_path) != nil  {
                            images2.append(AlamofireSource(urlString: image_path)!)
                        }
                   // images2.append(AlamofireSource(urlString: image_path)!)

                    }
                    // self.slideShow.setImageInputs(<#T##inputs: [InputSource]##[InputSource]#>)
                    //  self.scrollView.auk.show(url: "https://api.snapgroup.co.il\((image.path)!)")
                }
            
            self.slideShow.setImageInputs(images2)
                
//                DispatchQueue.main.sync {
//                    self.slideShow.setImageInputs(images2!)
//                }
                
                
                
            
            //print("===== MOODY \(self.groupImages)")
            
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
        
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
    func setGroupDetails(){
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
        var days = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day! as? Int
        var hours = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour! as? Int
        print("days: \(days!) , hours: \(hours!)")
        if days! < 0 || hours! < 0 {
            self.leftToJoinLbl.text = "Closed"
        }
        else{
            self.leftToJoinLbl.text = "\(days!) d' \(hours!) h' to join"
        }
        
     //   print(date)
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
            var urlString: String = ApiRouts.Web + (singleGroup?.group_leader_image!)!
            var url = URL(string: urlString)
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
