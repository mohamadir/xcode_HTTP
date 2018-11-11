//
//  Colors.swift
//  Snapgroup
//
//  Created by snapmac on 3/11/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import UIKit
struct Colors{
    static let whiteLight : UIColor = UIColor(rgb: 0xf1f1f1)
    static let PrimaryColor : UIColor = UIColor(rgb: 0xC1B46A)
    static let InboxItemBg : UIColor = UIColor(rgb: 0xE5E1C3)
    static let grayDarkColor : UIColor = UIColor(rgb: 0x434343)
    static let grayColor : UIColor = UIColor(rgb: 0xBFBFBF)
    static let backgroundStatusBar : UIColor = UIColor(rgb: 0x968527)
    static let blackLight : UIColor = UIColor(rgb: 0x4c4c4c)
     static let paymentsBacground : UIColor = UIColor(rgb: 0xF3F4F4)
    
    

    

}
class Colors3 {
    var gl:CAGradientLayer!
    
    init() {
        
        self.gl = CAGradientLayer()
        self.gl.colors = [UIColor.white.cgColor, Colors.PrimaryColor.cgColor,UIColor.white.cgColor]
        self.gl.locations = [0.0, 0.5, 1.0]
        
    }
}
