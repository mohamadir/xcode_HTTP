//
//  checkListCustomCellController.swift
//  Snapgroup
//
//  Created by snapmac on 4/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class checkListCustomCellController: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    
    @IBOutlet weak var itemSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

