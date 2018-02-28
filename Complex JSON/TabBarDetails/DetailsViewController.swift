//
//  DetailsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/25/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import Auk
import UserNotifications
import SocketIO
import ImageSlideshow
import SwiftHTTP
class DetailsViewController: UIViewController {

    let cvv: ViewController  = ViewController()
     var groupImages: [GroupImage] = []
    @IBOutlet weak var scrollView: UIScrollView!
    var singleGroup: TourGroup?

    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var titleLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.singleGroup  = MyVriables.currentGroup!
        let groupRequest = Main()
        titleLabel.text = singleGroup?.title
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
       // slideShow.draggingEnabled = false
        slideShow.isMultipleTouchEnabled = false
        slideShow.pageControlPosition = .insideScrollView
//        slideShow.pageControlPosition = .custom(padding: CGFloat(12))
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        groupRequest.getGroupImages(id:( singleGroup?.id)!){ (output) in
            self.groupImages = output!
            
                print("%%% \(self.groupImages.count)")
                var images2: [InputSource] = []

                  // var images2: [InputSource]?
                for image in self.groupImages {
                    if image.path !=  nil {
                    let image_path: String = "https://api.snapgroup.co.il\(image.path!)"
                    print("%%%%%%%%%%%%%%%%%%%% \(image_path)")
                        if AlamofireSource(urlString: image_path) != nil  {
                            images2.append(AlamofireSource(urlString: image_path)!)
                        }
                   // images2.append(AlamofireSource(urlString: image_path)!)

                    }
                    // self.slideShow.setImageInputs(<#T##inputs: [InputSource]##[InputSource]#>)
                    //  self.scrollView.auk.show(url: "https://api.snapgroup.co.il\((image.path)!)")
                }
            
            self.slideShow.setImageInputs(images2)
                
//                DispatchQueue.main.sync {
//                    self.slideShow.setImageInputs(images2!)
//                }
                
                
                
            
            print("===== MOODY \(self.groupImages)")
            
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }

}
