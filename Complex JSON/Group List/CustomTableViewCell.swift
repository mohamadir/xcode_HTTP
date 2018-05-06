//
//  CustomTableViewCell.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageosh: UIImageView!
    @IBOutlet weak var totalMembersLbl: UILabel!
    @IBOutlet weak var startDayLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var groupLeaderLbl: UILabel!
    @IBOutlet weak var groupLeaderImageView: UIImageView!
    
    @IBOutlet weak var totalDaysLbl: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var privateIcon: UIImageView!
    @IBOutlet weak var openIcon: UIImageView!
    @IBOutlet weak var leaderIcon: UIImageView!
    @IBOutlet weak var memberIcon: UIImageView!
    @IBOutlet weak var inviteIcon: UIImageView!
    @IBOutlet weak var timeOutIcon: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



}
