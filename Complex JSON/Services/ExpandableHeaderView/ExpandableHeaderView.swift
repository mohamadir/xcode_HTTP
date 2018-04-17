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

class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate){
        self.textLabel?.text = title
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
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       self.textLabel?.textColor = UIColor.black
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.contentView.backgroundColor = UIColor.white
    }
    
    
    
   // func custominit(title: String, section: Int, delegate: Expandable)

}
