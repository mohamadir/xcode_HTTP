//
//  MeTextCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 7.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class MeTextCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
