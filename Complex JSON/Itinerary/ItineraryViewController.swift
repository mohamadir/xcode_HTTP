//
//  ItineraryViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import PageControl
import SwiftHTTP
import BmoViewPager
class ItineraryViewController: UIViewController, BmoViewPagerDelegate, BmoViewPagerDataSource, UIPickerViewDelegate, UIPickerViewDataSource{
   
    
    
    @IBOutlet weak var daysPicker: UIPickerView!
    var rotationAngle: CGFloat!
    var array: [Int] = [1,2,3,4,5]
    var singleGroup: TourGroup?
    
    @IBOutlet weak var bmoPageViewer: BmoViewPager!
    var planDays: [Day] = []
    var pickerData: [String] = ["1","2","3"]
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row]
//    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return planDays.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
       return  60
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bmoPageViewer.presentedPageIndex  = row
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow  row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.frame = CGRect(x: 0 , y: 0 , width: 60, height: 40)
        let label = UILabel()
        label.numberOfLines = 0
        label.frame = CGRect(x: 0 , y: 0 , width: 60, height: 40)
   //     label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        
      
        
    
        label.textAlignment = .center
        label.font = UIFont(name:"HelveticaNeue-Bold" , size: 12)
        label.text = "Day\n\(self.planDays[row].day_number!)"
        if #available(iOS 11.0, *) {
            label.textColor = UIColor(named: "Primary")
        } else {
            // Fallback on earlier versions
            label.textColor = Colors.PrimaryColor
        }
        label.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )

        view.addSubview(label)
        
        return view

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("im here ")
        daysPicker.delegate = self
        daysPicker.dataSource = self
        rotationAngle = -1 * (90 * (.pi/180))
        bmoPageViewer.delegate = self
        bmoPageViewer.dataSource = self
        
        
        
        
        
        
//
        daysPicker.transform = CGAffineTransform(rotationAngle: rotationAngle )
     //   var y = daysPicker.frame.origin.y
//
        daysPicker.frame = CGRect(x: 0 , y: 0, width: view.frame.width , height: 45)
//        let shadowPath = UIBezierPath()
//        shadowPath.move(to: CGPoint(x: daysPicker.bounds.origin.y, y: daysPicker.frame.size.width))
//        shadowPath.addLine(to: CGPoint(x: daysPicker.bounds.height / 2, y: daysPicker.bounds.width + 7.0))
//        shadowPath.addLine(to: CGPoint(x: daysPicker.bounds.height, y: daysPicker.bounds.width))
//        shadowPath.close()
//
//        daysPicker.layer.shadowColor = UIColor.darkGray.cgColor
//        daysPicker.layer.shadowOpacity = 1
//        daysPicker.layer.masksToBounds = false
//        daysPicker.layer.shadowPath = shadowPath.cgPath
//        daysPicker.layer.shadowRadius = 5
        
     //   bmoPageViewer.presentedPageIndex = 2
        daysPicker.layer.shadowColor = UIColor.gray.cgColor
        daysPicker.layer.masksToBounds = false
        daysPicker.layer.shadowOffset = CGSize(width: 0.0 , height: 5.0)
        daysPicker.layer.shadowOpacity = 1.0
        daysPicker.layer.shadowRadius = 1.0

        self.singleGroup  = MyVriables.currentGroup!
        getDays()
        
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Day"
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    @IBAction func onBackTapped(_ sender: Any) {
          navigationController?.popViewController(animated: true)
    }
    
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return planDays.count
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        print("im here datasource")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DayPlan") as! ItemViewController
        vc.number = self.planDays[page].day_number!
        vc.dayDescription = (self.planDays[page] != nil && self.planDays[page].description != nil)  ? self.planDays[page].description! : "לא קיים תיאור עבור יום זה"
        vc.dayTitle = (self.planDays[page] != nil && self.planDays[page].title != nil)  ? self.planDays[page].title! : "לא קיים תיאור עבור יום זה"
        vc.date = (self.planDays[page] != nil && self.planDays[page].date != nil)  ? self.planDays[page].date! : "לא קיים תיאור עבור יום זה"
        vc.currentDay = self.planDays[page]
        if self.planDays[page].images?.count != 0 {
            vc.dayImagePath = (self.planDays[page].images?[0].path!)!
            print(vc.dayImagePath)
        }
        return vc
    }
    
    func bmoViewPagerDelegate(_ viewPager: BmoViewPager, pageChanged page: Int) {
        self.daysPicker.selectRow(page, inComponent: 0, animated: true)
        print("PageChanged \(page)")
    }
    
    func getDays(){
        print("----!!!!!!----"+ApiRouts.Web+"/api/days/group/\((self.singleGroup?.id!)!)")
        HTTP.GET(ApiRouts.Api+"/days/group/\((self.singleGroup?.id!)!)") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                    let days  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                    self.planDays = days.days!
                    DispatchQueue.main.sync {
                        self.bmoPageViewer.reloadData()
                        self.daysPicker.reloadAllComponents()
                    }
                
               }
          catch let error{
                    print(error)
                }
        //    print("opt finished: \(response.description)")
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }
   
    

    
    
}
