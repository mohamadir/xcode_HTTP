//
//  MenuViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/26/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
class MenuViewController: UIViewController {

    @IBOutlet weak var groupNameLbl: UILabel!
    var singleGroup: TourGroup?
    var countdownTimer: Timer!
    var totalTime = 60
    let date = Date()
    let formatter = DateFormatter()
    @IBOutlet weak var counterLbl: UILabel!
    
    @IBOutlet weak var membersView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.singleGroup  = MyVriables.currentGroup!
        self.groupNameLbl.text = singleGroup?.title
        self.groupNameLbl.numberOfLines = 0
        self.groupNameLbl.lineBreakMode = .byWordWrapping
     //   self.membersTp.addTarget(self, action: #selector(membersClick), for: .touchUpInside)
        membersView.addTapGestureRecognizer {
               self.performSegue(withIdentifier: "showMembers", sender: self)
        }
        startTimer()
        // Do any additional setup after loading the view.
    }
    @objc func membersClick(){
        print("tapped")
        
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
    
//    @IBAction func goToMembers(_ sender: Any) {
//        print("pressed")
//        performSegue(withIdentifier: "showMembers", sender: self)
//
//    }
 
    
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
 
    
    
    

}
