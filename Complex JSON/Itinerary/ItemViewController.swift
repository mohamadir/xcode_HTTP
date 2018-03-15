//
//  ItemViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
class ItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    
    // views
    @IBOutlet weak var dayTitleLb: UILabel!
    @IBOutlet weak var dayNumberLbl: UILabel!
    @IBOutlet weak var dayImageView: UIImageView!
    @IBOutlet weak var counterLb: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var transportsView: UIView!
    @IBOutlet weak var tourGuideView: UIView!
    // variabls
    public var number: Int = 0
    public var daynNumber: Int = 0
    public var dayImagePath: String =  ""
    public var date: String = ""
    public var dayDescription: String = ""
    public var dayTitle: String = ""
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
       dayNumberLbl.text = "\(number)"
        print("im here item veiw")
       descriptionLbl.text = dayDescription
        dateLbl.text = date
        dayTitleLb.text = dayTitle
        tourGuideView.frame.size.height = 0
        transportsView.frame.size.height = 0
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
