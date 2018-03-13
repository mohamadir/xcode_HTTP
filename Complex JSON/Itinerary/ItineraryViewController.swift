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
class ItineraryViewController: UIViewController, BmoViewPagerDelegate, BmoViewPagerDataSource{
   
    var array: [Int] = [1,2,3,4,5]
    var singleGroup: TourGroup?
    @IBOutlet weak var bmoPageViewer: BmoViewPager!
    var planDays: [Day] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("im here ")
        bmoPageViewer.delegate = self
        bmoPageViewer.dataSource = self
        
        bmoPageViewer.presentedPageIndex = 2
        self.singleGroup  = MyVriables.currentGroup!
        getDays()
        
        
    }
    
    
    
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return planDays.count
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        print("im here datasource")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DayPlan") as! ItemViewController
        vc.number = page
        
        return vc
    }
    
    
    
    func getDays(){
        HTTP.GET(ApiRouts.Web+"/api/days/group/\((self.singleGroup?.id!)!)") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                    let days  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                    self.planDays = days.days!
                    DispatchQueue.main.sync {
                        self.bmoPageViewer.reloadData()

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
