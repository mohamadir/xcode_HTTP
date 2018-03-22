//
//  CheckListItemCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 21.3.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class CheckListItemCell: UITableViewCell {

    
    @IBOutlet weak var itemSwitch: UISwitch!
    @IBOutlet weak var itemLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
