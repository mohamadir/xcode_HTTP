//
//  ExpandableHeaderView.swift
//  Snapgroup
//
//  Created by snapmac on 3/18/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
    
}
///defaultCell.imageService.image = UIImage(named: rowData.imageName)
class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    


    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var titlelabel: UILabel!
    
    
    
    func customInit(title: String , subtrig: String, section: Int, delegate: ExpandableHeaderViewDelegate){
        self.titlelabel.text = title
       self.headerImage.image = UIImage(named: subtrig)
        self.section = section
        self.delegate = delegate
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer){
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       self.titlelabel?.textColor = UIColor.black
        self.titlelabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.contentView.backgroundColor = UIColor.white
    }
    
    
    
   // func custominit(title: String, section: Int, delegate: Expandable)

}
