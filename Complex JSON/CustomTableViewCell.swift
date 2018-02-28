//
//  CustomTableViewCell.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageosh: UIImageView!
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var groupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
