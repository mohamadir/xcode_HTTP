//
//  memberMap.swift
//  Snapgroup
//
//  Created by snapmac on 7/1/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import UIKit
protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
}

class MapMarkerWindow: UIView {
    
    
    @IBOutlet weak var viewclick: UIView!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var wazeView: UIView!
    @IBOutlet weak var locationName: UILabel!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
