//
//  HelpCenterViewController.swift
//  Snapgroup
//
//  Created by snapmac on 8/5/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import WebKit


class HelpCenterViewController: UIViewController, UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate {
    @IBOutlet weak var coverWebView: UIView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var webview : WKWebView? = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        webview?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.coverWebView.frame.height)
        //webview?.frame = self.coverWebView.bounds
        //   self.coverWebView = webview!
        // self.coverWebView.frame = (webview?.frame)!
        
        var urlString: String = "https://www.snapgroup.co/snapgroup-help-pages"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        progress.show()
        //webview.load(urlRequest)
        self.webview?.load(URLRequest(url: NSURL(string:
            urlString)! as URL))
        self.webview?.navigationDelegate = self
        
        // self.webview?.allowsBackForwardNavigationGestures = true
        // self.webview?.scrollView.bounces = true
        //  self.webview?.sizeToFit()
        self.coverWebView.addSubview(self.webview!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func webViewDidStartLoad(_ webView: UIWebView) {
        progress.show()
        webView.frame = self.coverWebView.frame
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        progress.hide()
        progress.isHidden = true
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
