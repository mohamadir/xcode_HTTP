
//
//  VideoTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 8/7/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import VideoPlaybackKit

class VideoTableViewCell: UITableViewCell, VPKViewInCellProtocol {
    static let identifier = "VideoCell"
    var videoView: VPKVideoView? {
        didSet {
            self.setupVideoViewConstraints()
            layoutIfNeeded()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForVideoReuse() //Extension default
    }
}
