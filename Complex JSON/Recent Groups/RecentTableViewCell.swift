//
//  RecentTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 5/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
