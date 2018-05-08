//
//  PartnerViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 5/7/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class PartnerViewCell: UITableViewCell {

    @IBOutlet weak var recMessageView: DesignableView!
    @IBOutlet weak var recMessageLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
