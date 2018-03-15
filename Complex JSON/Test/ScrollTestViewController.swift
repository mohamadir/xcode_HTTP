//
//  ScrollTestViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/13/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ScrollTestViewController: UIViewController {

    @IBOutlet weak var myDynamicLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        myDynamicLabel.text = """
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaa
        bla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaabla bla blaaaaaa
        
        """
        myDynamicLabel.sizeToFit()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
