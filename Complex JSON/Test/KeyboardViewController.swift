//
//  KeyboardViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        
        // 2
        
        nav?.backgroundColor = UIColor.white
        // 3
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        
        // 4
        let image = UIImage(named: "default user")
        imageView.image = image
        
        // 5
        navigationItem.titleView = imageView
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        moveTextField(textField, moveDistance: -250, up: false)

    }
    
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("end end end end end " )
        if #available(iOS 10.0, *) {
            // use the feature only available in iOS 9
            // for ex. UIStackView
        } else {
            moveTextField(textField, moveDistance: -250, up: true)
            // or use some work around
        }
        textField.resignFirstResponder()
        return true
    }
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
   
   
   
    

}
