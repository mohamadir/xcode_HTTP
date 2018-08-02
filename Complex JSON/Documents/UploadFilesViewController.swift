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
import SwiftHTTP




class UploadFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider, WKNavigationDelegate {

    @IBOutlet weak var viewNoFiles: UIView!
    @IBOutlet weak var tableView: UITableView!
    var documents: DownloadDocObject?

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
        if documents?.files != nil
        {
            return (documents?.files.count)!
        }
        else
        {
            return 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        viewNoFiles.isHidden = true
        getFilesUpload()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "webViewCell", for: indexPath) as! WebViewCell
        cell2.selectionStyle = .none
        
        let webview = WKWebView()
        webview.frame  = CGRect(x: 0, y: 0, width: cell2.viewWebV.bounds.width, height: cell2.viewWebV.bounds.height)
      
       
        
       webview.navigationDelegate = self
        cell2.erorMesage.isHidden = true
        webview.tag = indexPath.row
        webview.scrollView.isScrollEnabled = false
        cell2.viewWebView.layer.borderWidth = 1
        cell2.viewWebView.layer.borderColor = UIColor.gray.cgColor
        cell2.viewWebView.layer.shadowColor = UIColor.black.cgColor
        cell2.viewWebView.layer.shadowOpacity = 1
        cell2.viewWebView.layer.shadowOffset = CGSize.zero
        cell2.viewWebView.layer.shadowRadius = 1
        cell2.indictorProgress.show()
        cell2.tag = indexPath.row
        var urlString: String = ApiRouts.Media + (self.documents?.files[indexPath.row].path)!
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        if verifyUrl(urlString: urlString)
        {
                           webview.load(URLRequest(url: NSURL(string:
                                urlString)! as URL))
        }
        else
        {
            cell2.indictorProgress.isHidden = true
            cell2.erorMesage.isHidden = false
        }
        
        cell2.viewWebV.addSubview(webview)

        cell2.viewOverWeb.addTapGestureRecognizer {
            print("clickible \(indexPath.row)")
        }
        if self.documents?.files[indexPath.row].original_filename != nil
        {
            cell2.fileName.text = (self.documents?.files[indexPath.row].original_filename)!
        }
        cell2.vieClickWebView.addTapGestureRecognizer {
            if (self.documents?.files[indexPath.row].path) != nil {
                var urlString2: String = ApiRouts.Media + (self.documents?.files[indexPath.row].path)!
                print("urlString2 \(urlString2)")
                urlString2 = urlString2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            MyVriables.currntUrl = urlString2
                MyVriables.currentType = (self.documents?.files[indexPath.row].mime)!
                MyVriables.fileName = (self.documents?.files[indexPath.row].original_filename)!
            }
           self.performSegue(withIdentifier: "showWebView", sender: self)
        }
        
        
    
        return cell2
    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("yessss \(webView.tag)")
        tableView?.visibleCells.forEach { cell in
           
                if let cell = cell as? WebViewCell {
                     if cell.tag == webView.tag {
                            cell.indictorProgress.hide()
                        cell.indictorProgress.isHidden = true
                    }
                }

        }
        
    }

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
        WKNavigation!, withError error: Error) {
        print("noooo \(webView.tag)")
        tableView?.visibleCells.forEach { cell in
            
            if let cell = cell as? WebViewCell {
                if cell.tag == webView.tag {
                    cell.indictorProgress.hide()
                    cell.indictorProgress.isHidden = true
                    cell.erorMesage.isHidden = false
                }
            }
            
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("noooo \(webView.tag)")
        tableView?.visibleCells.forEach { cell in

            if let cell = cell as? WebViewCell {
                if cell.tag == webView.tag {
                    cell.indictorProgress.hide()
                    cell.indictorProgress.isHidden = true
                    cell.erorMesage.isHidden = false
                }
            }

        }
    }
    func getFilesUpload() {
        

        HTTP.GET(ApiRouts.Api+"/files/group/\((MyVriables.currentGroup?.id)!)", parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                self.documents = try JSONDecoder().decode(DownloadDocObject.self, from: response.data)
                print("The Array is \(self.documents!)")
                if (self.documents?.files.count)! == 0
                {
                    DispatchQueue.main.sync {
                    self.viewNoFiles.isHidden = false
                    }
                }
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }
    
    



   

}

