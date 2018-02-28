//
//  MenuViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/26/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var groupNameLbl: UILabel!
    var singleGroup: TourGroup?
    var countdownTimer: Timer!
    var totalTime = 60
    let date = Date()
    let formatter = DateFormatter()
    @IBOutlet weak var counterLbl: UILabel!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.singleGroup  = MyVriables.currentGroup!
        self.groupNameLbl.text = singleGroup?.title
        self.groupNameLbl.numberOfLines = 0
        self.groupNameLbl.lineBreakMode = .byWordWrapping
//        self.membersView.addTarget(self, action: #selector(membersTap), for: .touchUpInside)

        startTimer()
        // Do any additional setup after loading the view.
    }
   
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        counterLbl.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
 
    
    
    

}
