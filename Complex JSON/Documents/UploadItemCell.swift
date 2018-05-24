//
//  UploadItemCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 21.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class UploadItemCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var isFileExists: UIImageView!
    @IBOutlet weak var mimeImageBt: UIImageView!
    
}
