//
//  MemberMap.swift
//  Snapgroup
//
//  Created by snapmac on 7/2/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAvatar

class MemberMapView: UIView {
    
    
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var lastSeen: UILabel!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberImage: SwiftyAvatar!
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MemberMapView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
}
}
