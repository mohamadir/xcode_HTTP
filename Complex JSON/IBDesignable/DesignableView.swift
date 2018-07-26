//
//  DesignableView.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    @IBInspectable var cornerRaduis: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRaduis
        }

    }
    
    

}
