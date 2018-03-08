//
//  MemberModalViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/8/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class MemberModalViewController: UIViewController {

    @IBOutlet weak var memberView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        memberView.layer.shadowColor = UIColor.black.cgColor
        memberView.layer.shadowOpacity = 0.5
        memberView.layer.shadowOffset = CGSize.zero
        memberView.layer.shadowRadius = 4
        // Do any additional setup after loading the view.
    }

   
    @IBAction func onCloseTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
