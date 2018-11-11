//
//  ItemViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
import GoneVisible
class ItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    
    // views
    @IBOutlet weak var dayTitleLb: UILabel!
    @IBOutlet weak var dayNumberLbl: UILabel!
    @IBOutlet weak var dayImageView: UIImageView!
    @IBOutlet weak var counterLb: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    // services views
    
    @IBOutlet weak var hotelsView: UIView!
    @IBOutlet weak var activitiesView: UIView!
    @IBOutlet weak var restaurantView: UIView!
    @IBOutlet weak var transportsView: UIView!
    @IBOutlet weak var tourGuideView: UIView!
    @IBOutlet weak var placesViews: UIView!
    @IBOutlet weak var stackServices: UIStackView!
    
    // services labels views
    @IBOutlet weak var hotelsLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var activitiesLbl: UILabel!
    @IBOutlet weak var placesLbl: UILabel!
    @IBOutlet weak var transportsLbl: UILabel!
    @IBOutlet weak var toursLbl: UILabel!
    
    @IBOutlet weak var scrolViewInterry: UIScrollView!
    // variabls
    public var number: Int = 0
    public var daynNumber: Int = 0
    public var dayImagePath: String =  ""
    public var date: String = ""
    public var dayDescription: String = ""
    public var dayTitle: String = ""
    
    public var currentDay: Day?
    
    
    fileprivate func viewsClicked() {
        restaurantView.addTapGestureRecognizer {
            //
            
            ProviderInfo.currentProviderName =  "Restaurants"
            
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.restaurants?.count)!)")
            //self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            //showServiceModalSeque
            if  (self.currentDay?.restaurants?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.restaurants?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
                //                let vc = ServiceModalViewController()
                //                self.present(vc, animated: true, completion: nil)
                
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.restaurants)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
            
            
        }
        hotelsView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.hotels?.count)!)")
            
            ProviderInfo.currentProviderName =  "Hotels"
            if  (self.currentDay?.hotels?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.hotels?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.hotels)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
        }
        activitiesView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.activities?.count)!)")
            
            ProviderInfo.currentProviderName =  "Activities"
            if   (self.currentDay?.activities?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.activities?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.activities)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
        }
        placesViews.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.places?.count)!)")
            
            ProviderInfo.currentProviderName =  "Places"
            if   (self.currentDay?.places?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.places?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.places)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
        }
        transportsView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.transports?.count)!)")
            ProviderInfo.currentProviderName =  "Transport"
            if  (self.currentDay?.transports?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.transports?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.transports)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
        }
        tourGuideView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.tour_guides?.count)!)")
            
            ProviderInfo.currentProviderName =  "Tourguides"
            if   (self.currentDay?.tour_guides?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.tour_guides?[0].id
                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.tour_guides)!
                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       dayNumberLbl.text = "\(number)"
        print("im here item veiw")
       descriptionLbl.text = dayDescription
        dateLbl.text = date
        dayTitleLb.text = dayTitle
        print(self.currentDay!)
        setHiddenServices()
        
        if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"
        {
            dateLbl.isHidden = true
            // MyVriables.currentGroup.reg
        }else{
            dateLbl.isHidden = false
        }
        if dayImagePath == nil || dayImagePath == "" {
            dayImageView.image = UIImage(named: "Group Placeholder")
        }
        else{
            var urlString = ApiRouts.Media + dayImagePath
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            var url = URL(string: urlString)
            //print("URL STRING \(url!)")
//            do{
//                try dayImageView.downloadedFrom(url: url!)
//            }
//            catch let error{
//                print(error)
//            }
            if url != nil{
                dayImageView.sd_setShowActivityIndicatorView(true)
                dayImageView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                dayImageView.sd_setImage(with: url!, completed: nil)
            }
        }
        viewsClicked()
        print("Scroll view \(scrolViewInterry.heightAnchor)")
    }
    
    
    func setHiddenServices() {
        let hotelInStack = stackServices.arrangedSubviews[0]
        let resturantInStack = stackServices.arrangedSubviews[1]
        let activitiesInStack = stackServices.arrangedSubviews[2]
        let placesInStack = stackServices.arrangedSubviews[3]
        let transportsInStack = stackServices.arrangedSubviews[4]
        let tourInStack = stackServices.arrangedSubviews[5]
        
        if self.currentDay?.activities?.count == 0 {
            activitiesInStack.isHidden = true
        }
        else{
            var str: String = ""
            for act in (self.currentDay?.activities!)! {
                str.append("\((describing: act.name!)) ")
            }
            activitiesLbl.text = str
        }
        if self.currentDay?.restaurants?.count == 0 {
            resturantInStack.isHidden = true
        }else{
            var str: String = ""
            for (i,act) in (self.currentDay?.restaurants!)!.enumerated() {
                if i !=  ((self.currentDay?.restaurants!)!.count - 1) {
                    str.append("\((act.translations?[0].name!)!) ,")
                }else{
                    str.append("\((act.translations?[0].name!)!)")
                }
            }
            restLabel.text = str
        }
        if self.currentDay?.hotels?.count == 0 {
            hotelInStack.isHidden = true
        }else{
            var str: String = ""
            for (i,act) in (self.currentDay?.hotels!)!.enumerated() {
                if i !=  ((self.currentDay?.hotels!)!.count - 1) {
                    str.append("\((act.translations?[0].name!)!) ,")
                }else{
                    str.append("\((act.translations?[0].name!)!)")
                }

                
            }
            hotelsLabel.text = str
        }
        if self.currentDay?.places?.count == 0 {
            placesInStack.isHidden = true
        }else{
            var str: String = ""
            for (i,act) in (self.currentDay?.places!)!.enumerated() {
                if i !=  ((self.currentDay?.places!)!.count - 1) {
                        str.append("\((describing: act.name!)) ,")
                    
                }else{
                    str.append("\((describing: act.name!))")
                }
              
            }
            placesLbl.text = str
        }
        if self.currentDay?.tour_guides?.count == 0 {
            tourInStack.isHidden = true
        }else{
            var str: String = ""
            for (i,act) in (self.currentDay?.tour_guides!)!.enumerated() {
                
                if i !=  ((self.currentDay?.tour_guides!)!.count - 1) {
                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!) ,")

                }else{
                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!)")
                }
                
            }
            toursLbl.text = str
        }
        if self.currentDay?.transports?.count == 0 {
            transportsInStack.isHidden = true
        }else{
            var str: String = ""
            for (i,act) in (self.currentDay?.transports!)!.enumerated() {
                if i !=  ((self.currentDay?.transports!)!.count - 1) {
                    str.append("\((describing: act.company_name!)) ,")

                }else{
                    str.append("\((describing: act.company_name!))")
                }
            }
            transportsLbl.text = str
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    


}

extension UIView {
    
    func goAway() {
        // set the width constraint to 0
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
        superview!.addConstraint(widthConstraint)
        
        // set the height constraint to 0
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
        superview!.addConstraint(heightConstraint)
    }
    
}
