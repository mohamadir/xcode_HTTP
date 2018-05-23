//
//  NewDocsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/8/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import Digger
import Alamofire
import SVProgressHUD
import XLPagerTabStrip

class NewDocsViewController: ButtonBarPagerTabStripViewController {
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    
    @IBAction func onBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
   
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 1.0
        settings.style.selectedBarBackgroundColor = Colors.PrimaryColor
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = Colors.PrimaryColor
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let downbload = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "child1")
        let upload = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "child2")
        return [downbload, upload]
    }

//    @IBAction func downloadTapped(_ sender: Any) {
//        //        print("DOWNLOADTEST- in download tapped")
//        //        HTTP.Download("https://api.snapgroup.co.il/api/groups/72/pdf", completion: { (response, url) in
//        //            if response.error != nil {
//        //                print("DOWNLOADTEST- error download - \(response.error)")
//        //                return
//        //            }
//        //            print("DOWNLOADTEST- \(url)")
//        //            //move the temp file to desired location...
//        //        })
//        let urlString = "https://files.slack.com/files-pri/T67LB372T-F9LRUBCA1/chat_bar_icon2.png"
//      SVProgressHUD.show()
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            let documentsURL:NSURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first! as NSURL
//            print("***documentURL: ",documentsURL)
//            let fileURL = documentsURL.appendingPathComponent("11.png")
//            print("***fileURL: ",fileURL ?? "")
//            return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
//        }
//
//        Alamofire.download(urlString, to: destination).downloadProgress(closure: { (prog) in
//        }).response { response in
//            //print(response)
//            SVProgressHUD.dismiss()
//            if response.error == nil, let filePath = response.destinationURL?.path {
//                print("mmmm",filePath)
//            }
//        }
//    }
    //

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
//    class Downloader {
//        class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
//            let sessionConfig = URLSessionConfiguration.default
//            let session = URLSession(configuration: sessionConfig)
//            let request = try! URLRequest(url: url, method: .get)
//
//            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
//                if let tempLocalUrl = tempLocalUrl, error == nil {
//                    // Success
//                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                        print("Success: \(statusCode)")
//                    }
//
//                    do {
//                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
//                        completion()
//                    } catch (let writeError) {
//                        print("error writing file \(localUrl) : \(writeError)")
//                    }
//
//                } else {
//                    print("Failure: %@", error?.localizedDescription);
//                }
//            }
//            task.resume()
//        }
//    }
}
