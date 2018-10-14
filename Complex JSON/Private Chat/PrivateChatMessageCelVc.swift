//
//  PrivateChatMessageCelVc.swift
//  Snapgroup
//
//  Created by snapmac on 3/4/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class PrivateChatMessageCelVc: UITableViewCell {

    @IBOutlet weak var sentMessageView: DesignableView!
    @IBOutlet weak var sentMessageLbl: UILabel!
    @IBOutlet weak var time: UILabel!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
