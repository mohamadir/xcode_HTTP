//
//  ImagePartnerCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 8.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftyAvatar

class ImagePartnerCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var imageViewClick: UIView!
    @IBOutlet weak var partnerName: UILabel!
    @IBOutlet weak var partnerImage: SwiftyAvatar!
    @IBOutlet weak var partnerImageProfile: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
