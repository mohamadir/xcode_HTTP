//
//  WebViewCell.swift
//  Snapgroup
//
//  Created by hosen gaber on 23.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import WebKit

class WebViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var vieClickWebView: UIView!
    @IBOutlet weak var viewWebV: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var viewWebView: UIView!
    @IBOutlet weak var indictorProgress: UIActivityIndicatorView!
    @IBOutlet weak var erorMesage: UILabel!
    @IBOutlet weak var fileName: UILabel!
    
    @IBOutlet weak var viewOverWeb: UIView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
