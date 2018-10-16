//
//  WebViewViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 23.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var viewAddWebView: UIView!
    @IBOutlet weak var erorMesage: UILabel!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indictorProgress: UIActivityIndicatorView!
    var urlStringa: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        indictorProgress.startAnimating()
       viewShadow.layer.borderWidth = 1
        viewShadow.layer.borderColor = UIColor.gray.cgColor
        viewShadow.layer.shadowColor = UIColor.black.cgColor
       viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.shadowOffset = CGSize.zero
       viewShadow.layer.shadowRadius = 4
        if (MyVriables.fileName) != nil {
        fileName.text = (MyVriables.fileName)
        }
        imageView.isHidden = true
        indictorProgress.show()
        if true != true {
             indictorProgress.isHidden = true
          //  webView.isHidden = true
            imageView.isHidden = false
           
            var urlString: String =  (MyVriables.currntUrl)!
            if (MyVriables.currntUrl) != nil{
                print(urlString)
                
            }
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            if let url = URL(string: urlString) {
               imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "Group Placeholder"), completed: nil)
                
            }
            
        }
        else {
            let webview = WKWebView()
            webview.frame  = CGRect(x: 0, y: 0, width: viewAddWebView.bounds.width, height: viewAddWebView.bounds.height)
            viewAddWebView.addSubview(webview)
            
            //webView.isHidden = false
            imageView.isHidden = true
        webview.navigationDelegate = self
        if MyVriables.currntUrl != nil
        {
            urlStringa = MyVriables.currntUrl!
        }
            print("media.snapgroup.co======= \(urlStringa)")
        if verifyUrl(urlString: urlStringa)
        {
            
            webview.load(URLRequest(url: NSURL(string: urlStringa)! as URL))
        }
        else
        {
            indictorProgress.isHidden = true
            erorMesage.isHidden = false
        }
        }
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
            indictorProgress.hide()
            indictorProgress.isHidden = true

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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onBack(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    


}
