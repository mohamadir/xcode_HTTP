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
    
    
    // variabls
    public var number: Int = 0
    public var daynNumber: Int = 0
    public var dayImagePath: String =  ""
    public var date: String = ""
    public var dayDescription: String = ""
    public var dayTitle: String = ""
    
    public var currentDay: Day?
    override func viewDidLoad() {
        super.viewDidLoad()
       dayNumberLbl.text = "\(number)"
        print("im here item veiw")
       descriptionLbl.text = dayDescription
        dateLbl.text = date
        dayTitleLb.text = dayTitle
        print(self.currentDay!)
        setHiddenServices()
        
        
//        tourGuideView.gone()
//        transportsView.gone()
        
//        activitiesView.gone()
        if dayImagePath == nil || dayImagePath == "" {
            
        }
        else{
            var urlString = ApiRouts.Web + dayImagePath
            var url = URL(string: urlString)
            //print("URL STRING \(url!)")
//            do{
//                try dayImageView.downloadedFrom(url: url!)
//            }
//            catch let error{
//                print(error)
//            }
            if url != nil{
                dayImageView.sd_setImage(with: url!, completed: nil)

            }
        }
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
            
        }
        if self.currentDay?.restaurants?.count == 0 {
            resturantInStack.isHidden = true
        }else{
            
        }
        if self.currentDay?.hotels?.count == 0 {
            hotelInStack.isHidden = true
        }else{
            
        }
        if self.currentDay?.places?.count == 0 {
            placesInStack.isHidden = true
        }else{
            
        }
        if self.currentDay?.tour_guides?.count == 0 {
            tourInStack.isHidden = true
        }else{
            
        }
        if self.currentDay?.transports?.count == 0 {
            transportsInStack.isHidden = true
        }else{
            
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
