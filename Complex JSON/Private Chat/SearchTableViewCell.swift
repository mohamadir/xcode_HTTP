//
//  SearchTableViewCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 30.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var pesonImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
