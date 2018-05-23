//
//  UploadFilesViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 21.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit
class UploadFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!

    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Document to download")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        //        webView.load(URLRequest(url: NSURL(string: "http:////api.snapgroup.co.il/api/groups/221/pdf")! as URL))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCell", for: indexPath) as! DownloadCell
        cell.selectionStyle = .none
//        cell.progressBar.progress = 0.0
//        self.theBool = false
//
//        self.myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
//
//        cell.webView.navigationDelegate = self
//        cell.webView.load(URLRequest(url: NSURL(string:
//            "http://homepages.inf.ed.ac.uk/neilb/TestWordDoc.doc")! as URL))
        return cell
    }


   

}

