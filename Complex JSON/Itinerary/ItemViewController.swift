//
//  ItemViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    @IBOutlet weak var dayTitleLb: UILabel!
    @IBOutlet weak var dayNumberLbl: UILabel!
    @IBOutlet weak var dayImageView: UIImageView!
    public var number: Int = 0
    @IBOutlet weak var counterLb: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        counterLb.text = "\(number)"
        print("im here item veiw")
    }


}
