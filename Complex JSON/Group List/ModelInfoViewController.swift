//
//  ModelInfoViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 6.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ModelInfoViewController: UIViewController {

    @IBOutlet weak var modelView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modelView.layer.borderWidth = 2
        modelView.layer.borderColor = UIColor.gray.cgColor
        modelView.layer.shadowColor = UIColor.black.cgColor
        modelView.layer.shadowOpacity = 5
        modelView.layer.shadowOffset = CGSize.zero
        modelView.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBack(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    

}
