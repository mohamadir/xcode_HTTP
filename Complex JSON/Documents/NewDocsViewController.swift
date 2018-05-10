//
//  NewDocsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/8/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import FileBrowser


class NewDocsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func downloadTapped(_ sender: Any) {
//        print("DOWNLOADTEST- in download tapped")
//        HTTP.Download("https://api.snapgroup.co.il/api/groups/72/pdf", completion: { (response, url) in
//            if response.error != nil {
//                print("DOWNLOADTEST- error download - \(response.error)")
//                return
//            }
//            print("DOWNLOADTEST- \(url)")
//            //move the temp file to desired location...
//        })
        
        
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
    //
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
