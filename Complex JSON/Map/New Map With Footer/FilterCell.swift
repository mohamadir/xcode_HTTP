//
//  FilterCell.swift
//  Snapgroup
//
//  Created by snapmac on 7/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet weak var daySwitch: UISwitch!
    @IBOutlet weak var dayNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
