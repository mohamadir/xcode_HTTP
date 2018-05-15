//
//  AllReviewsTableViewCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 14.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftyAvatar

class AllReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var profileImage: SwiftyAvatar!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
