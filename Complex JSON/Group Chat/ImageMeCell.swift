//
//  ImageMeCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 8.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftyAvatar

class ImageMeCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var imageViewClick: DesignableView!
    @IBOutlet weak var meImage: SwiftyAvatar!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
