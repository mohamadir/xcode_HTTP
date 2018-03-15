//
//  ItineraryServiceViewControllerCell.swift
//  Snapgroup
//
//  Created by snapmac on 3/14/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ItineraryServiceViewControllerCell: UITableViewCell {

    
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
