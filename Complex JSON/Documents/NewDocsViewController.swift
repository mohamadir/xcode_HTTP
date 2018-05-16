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
        let url = "https://files.slack.com/files-pri/T67LB372T-F9LRUBCA1/chat_bar_icon2.png"
        
        Digger.download(url)
            .progress({ (progresss) in
                print(progresss.fractionCompleted)
                
            })
            .speed({ (speed) in
                print(speed)
            })
            .completion { (result) in
                
                switch result {
                case .success(let url):
                    print(url)
                    if var URL = URL(string: url.absoluteString) {
                        let documentDirectory = try! FileManager.default.url(for: .documentDirectory    , in: .userDomainMask, appropriateFor: nil, create: false)
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .long
                        dateFormatter.timeStyle = .short
                        let date = dateFormatter.string(from: Date())
                        let saveURL = documentDirectory.appendingPathComponent("fileodsfsdfsh.jpg")
                        print("MOHMD- absoluteUrlString: \(url.absoluteString) , URL : \(URL) , saveUrl: \(saveURL)")
                        
                        Downloader.load(url: URL, to: saveURL) {
                            print("ok")
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
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
    class Downloader {
        class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = try! URLRequest(url: url, method: .get)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
                    }
                    
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                        completion()
                    } catch (let writeError) {
                        print("error writing file \(localUrl) : \(writeError)")
                    }
                    
                } else {
                    print("Failure: %@", error?.localizedDescription);
                }
            }
            task.resume()
        }
    }
}
