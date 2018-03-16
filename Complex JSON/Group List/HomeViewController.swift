//
//  HomeViewController.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var textLbl: UILabel!
    var singleGroup: TourGroup?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        print("----- \(myVC.currentGroup)")
        textLbl.text = singleGroup?.title

        // Do any additional setup after loading the view.
    }



}
