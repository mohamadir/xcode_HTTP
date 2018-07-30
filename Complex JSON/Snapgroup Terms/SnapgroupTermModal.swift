//
//  SnapgroupTermModal.swift
//  Snapgroup
//
//  Created by snapmac on 7/29/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import WebKit
import SwiftEventBus


class SnapgroupTermModal: UIViewController, UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate, UIScrollViewDelegate{
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var webview : WKWebView? = WKWebView()
    @IBOutlet weak var coverWebView: UIView!
    @IBOutlet weak var overview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       // webview.frame =
       //webview.frame  = self.overview.frame
        webview?.frame = CGRect(x: 0, y: 0, width: self.coverWebView.frame.width, height: self.coverWebView.frame.height)
        webview?.frame = self.coverWebView.bounds
     //   self.coverWebView = webview!
       // self.coverWebView.frame = (webview?.frame)!
       
       
        var urlString: String = "https://www.snapgroup.co/end-user-licence-agreement"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        //webview.load(urlRequest)
        self.webview?.load(URLRequest(url: NSURL(string:
            urlString)! as URL))
        self.webview?.navigationDelegate = self

       // self.webview?.allowsBackForwardNavigationGestures = true
       // self.webview?.scrollView.bounces = true
      //  self.webview?.sizeToFit()
        self.coverWebView.addSubview(self.webview!)
    }
    @IBAction func onDismiss(_ sender: Any) {
        MyVriables.kindRegstir = ""

        self.dismiss(animated: true, completion: nil)
    }
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        if navigationType == .linkClicked
        {
            if let url_text = request.url?.absoluteURL {
                print("linkClicked:", url_text)
            }
        }
        return true;
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.frame = self.coverWebView.frame
    }
    
    @IBAction func scrollToBottom(_ sender: Any) {
        let scrollPoint = CGPoint(x: 0, y: webview!.scrollView.contentSize.height - webview!.frame.size.height)
        webview!.scrollView.setContentOffset(scrollPoint, animated: true)
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
    func webViewDidStartLoad(_ webView: UIWebView) {
        progress.show()
        webView.frame = self.coverWebView.frame

    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        progress.hide()
        progress.isHidden = true
    }
    
    @IBAction func agreeClick(_ sender: Any) {
        if MyVriables.kindRegstir == "phone"{
            MyVriables.kindRegstir = ""
            SwiftEventBus.post("termConfirm")
        }
        if MyVriables.kindRegstir == "phone-Regstir"{
            MyVriables.kindRegstir = ""
            SwiftEventBus.post("termConfirm-phone-Regstir")
        }
        if MyVriables.kindRegstir == "facebook-Regstir"{
                MyVriables.kindRegstir = ""
                SwiftEventBus.post("facebook-Regstir")

        }
        if MyVriables.kindRegstir == "phone-Header"{
                    MyVriables.kindRegstir = ""
                    SwiftEventBus.post("phone-Header")
                    
        }
        if MyVriables.kindRegstir == "facebook-Header"{
                        MyVriables.kindRegstir = ""
                        SwiftEventBus.post("facebook-Header")
        }
        if MyVriables.kindRegstir == "facebook-join"{
            MyVriables.kindRegstir = ""
            SwiftEventBus.post("facebook-join")
        }
        if MyVriables.kindRegstir == "phone-join"{
            MyVriables.kindRegstir = ""
            SwiftEventBus.post("phone-join")
        }
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func disagreeClick(_ sender: Any) {
        MyVriables.kindRegstir = ""
        self.dismiss(animated: true, completion: nil)

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("yessss \(webView.tag)")
        self.progress.hide()
        self.progress.isHidden = true
        webView.frame = self.coverWebView.frame
        
//        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        
        
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
        WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())

    }
    

}
