//
//  MainTabController.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import SwiftEventBus
import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate{
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //refreshGroupRole
        if MyVriables.IsFromArrival {
            self.selectedIndex = 0
            self.selectedIndex = 2
        }else {
            
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        print("main tab bar return from pop = in view did appear")
        if MyVriables.IsFromArrival {
            MyVriables.IsFromArrival = false
            self.selectedIndex = 2
            
        }


    //    self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
    //    self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item \(item.title) is true ? == \(item.title! == "Joined")")
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let tabBarIndex1 = tabBarController.selectedIndex
        print("Im in join tab controler \(tabBarIndex1)")
        if tabBarIndex1 == 1 {
            
           print("Im in join tab controler")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
      self.delegate = self

        //refreshGroupRolee
        print("from the Main")
    
        // self.tabBar.itmes?[i].image = UIIMage...
        
        let isOpen = MyVriables.currentGroup?.open!
        let role = MyVriables.currentGroup?.role
        // check availbality
        if #available(iOS 11.0, *) {
            self.tabBar.tintColor = UIColor(named: "Primary")
        } else {
             self.tabBar.tintColor = Colors.PrimaryColor
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.gray
        } else {
            // Fallback on earlier versions
        }
        self.tabBar.backgroundColor = UIColor.white
        var isGroupAvailable: Bool? = false
        if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"
        {
            isGroupAvailable = true
           // MyVriables.currentGroup.reg
        }
        else{
        if MyVriables.currentGroup?.registration_end_date != nil {
             isGroupAvailable = isAvailable(date: (MyVriables.currentGroup?.registration_end_date!)!)
            print("\(isGroupAvailable!)")
            
        }else{
                isGroupAvailable = isAvailable(date: (MyVriables.currentGroup?.start_date!)!)
        }
        }
        
            if role == nil {
                if isOpen == true  {
                    if isGroupAvailable! {
                        print("role = nil and is open ")
                        self.tabBar.items?[1].image = UIImage(named: "joinicon1")
                        self.tabBar.items?[1].title = "Interested"
                        MyVriables.roleStatus = "observer"
                     MyVriables.isAvailble = true
                    }
                    else
                    {
                        MyVriables.isAvailble = false
                        self.tabBar.items?[1].image = UIImage(named: "timeout")
                        self.tabBar.items?[1].title = "Closed"
                        //viewControllers?[1].removeFromParentViewController()
                    }
                    
                    //
                    
                }else{
                    print("role = nil and is close ")
                    MyVriables.isAvailble = false
                    self.tabBar.items?[1].image = UIImage(named: "timeout")
                    self.tabBar.items?[1].title = "Closed"
                    //viewControllers?[1].removeFromParentViewController()
                    // closed group - cannot enter group
                }
            }else if role! == "member" {
                print("role = member")
                self.tabBar.items?[1].image = UIImage(named: "joinedIcon1")
                self.tabBar.items?[1].title = "Interested"
                MyVriables.roleStatus = "member"
                MyVriables.isAvailble = true
                // leave group

            } else if role! == "group_leader" {
                print("role = group leader")
                self.tabBar.items?[1].image = UIImage(named: "joined")
                self.tabBar.items?[1].title = "Manage"
                //self.tabBar.items?[1].accessibilityElementsHidden = true
                MyVriables.roleStatus = "group_leader"
                MyVriables.isAvailble = true
                
                // hide item bar

            } else if role! == "observer" {
                print("role = observer")
                   if isGroupAvailable != nil && isGroupAvailable! {
                    self.tabBar.items?[1].image = UIImage(named: "joinicon1")
                    self.tabBar.items?[1].title = "Interested"
                    MyVriables.roleStatus = "observer"
                     MyVriables.isAvailble = true
                }
                else
                   {
                     MyVriables.isAvailble = false
                    self.tabBar.items?[1].image = UIImage(named: "timeout")
                    self.tabBar.items?[1].title = "Closed"
                    //viewControllers?[1].removeFromParentViewController()
                }
 



            }

     
        
    }
 
    func isAvailable(date: String) -> Bool{
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
        let month: Int = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).month!
        let year: Int = Calendar.current.dateComponents([.year,.hour,.minute,.month], from: currentDate, to: date2).year!
        print("days: \(days) , hours: \(hours) , month: \(month) ,year: \(year) ")
        if days < 0 || hours < 0 || month < 0  || year < 0 {
            return false
        }
        else{
            return true
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("disappershoisdk")
        SwiftEventBus.post("allocate")
        /*
         let sb = UIStoryboard(name: "Main", bundle: nil)
         var vc = sb.instantiateViewController(withIdentifier: "Web") as? WebViewController
         if vc != nil {
         vc = nil
         }
 */
    }
    
    
    public func changeToJoin(){
        self.tabBar.items?[1].image = UIImage(named: "joinedIcon1")
        self.tabBar.items?[1].title = "Interested"
        MyVriables.roleStatus = "member"
    }
}
