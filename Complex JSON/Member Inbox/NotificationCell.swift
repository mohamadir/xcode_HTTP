//
//  NotificationCell.swift
//  Snapgroup
//
//  Created by snapmac on 4/6/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var ItemView: UIView!
    
    @IBOutlet weak var messageIconImageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
