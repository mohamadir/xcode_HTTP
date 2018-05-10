//
//  ImageViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/7/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ImageSlideshow

class ImageViewController: UIViewController {
    
    
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = MyVriables.imageUrl
        let url = URL(string: urlString)
        print("--PRIVATECHAT \(urlString)")
        imageSlideShow.activityIndicator = DefaultActivityIndicator()
        imageSlideShow.circular = false
        imageSlideShow.zoomEnabled = true
        // slideShow.draggingEnabled = false
        imageSlideShow.isMultipleTouchEnabled = false
        imageSlideShow.pageControlPosition = .insideScrollView
        //        slideShow.pageControlPosition = .custom(padding: CGFloat(12))
        imageSlideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        var images2: [InputSource] = []
        images2.append(AlamofireSource(urlString: urlString)!)
        self.imageSlideShow.setImageInputs(images2)
        
        
//        imageView.sd_setImage(with: url! , placeholderImage: UIImage(named: "Group Placeholder"))
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
