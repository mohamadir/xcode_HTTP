//
//  ProviderViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 26.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import ImageSlideshow

class ProviderViewController: UIViewController {

  
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var fullName: UILabel!
    var providerModel : ProviderModel?
    override func viewDidLoad() {
        super.viewDidLoad()

       
        getProvider()
        
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
        // slideShow.draggingEnabled = false
        slideShow.isMultipleTouchEnabled = false
        slideShow.pageControlPosition = .insideScrollView
        //        slideShow.pageControlPosition = .custom(padding: CGFloat(12))
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProviderViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
    
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        do
        {
            dismiss(animated: true, completion: nil)
            
        }
        catch let error {
            print(error)
        }
    }
    func getUrlService() -> String{
        switch ProviderInfo.currentProviderName!{
        case "Hotels":
            return ApiRouts.Web+"/api/get/hotel/\((ProviderInfo.currentProviderId)!)"
        case "Places":
            return ApiRouts.Web+"/api/get/place/\((ProviderInfo.currentProviderId)!)"
        case "Restaurants":
            return ApiRouts.Web+"/api/get/restaurant/\((ProviderInfo.currentProviderId)!)"
        case "Tourguides":
            return ApiRouts.Web+"/api/get/tourguide/\((ProviderInfo.currentProviderId)!)"
        case "Transport":
            return ApiRouts.Web+"/api/get/transport/\((ProviderInfo.currentProviderId)!)"
        case "Activities":
            return ApiRouts.Web+"/api/get/activity/\((ProviderInfo.currentProviderId)!)"
        default:
            return "null"
        }
    }
    
    func getProvider(){
        HTTP.GET(getUrlService(), parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
          
             do{
                self.providerModel = try JSONDecoder().decode(ProviderModel.self, from: response.data)
                DispatchQueue.main.sync {
                   
                    
                    if self.providerModel?.description != nil
                    {
                        self.about.text = (self.providerModel?.description)!
                        
                    }
                    else
                    {
                        if self.providerModel?.bio != nil
                        {
                            self.about.text = (self.providerModel?.bio)!
                        }
                        else
                        {
                             self.about.text = "there is no info"
                        }
                        
                    }
                    if self.providerModel?.company_name != nil
                    {
                        self.fullName.text = (self.providerModel?.company_name)!
                    }
                    else
                    {
                        if self.providerModel?.name != nil
                        {
                          
                             self.fullName.text = (self.providerModel?.name)!
                        }
                        else
                        {
                            if self.providerModel?.first_name != nil && self.providerModel?.last_name != nil
                            {
                                self.fullName.text = "\((self.providerModel?.first_name)!) \((self.providerModel?.last_name)!)"
                               
                            }
                        
                        }
                        
                    }
                     self.location.text =  ( self.providerModel?.city != nil ? self.providerModel?.city : "there is not exits")!
                    if self.providerModel?.phone != nil
                    {
                         self.phoneNumber.text = self.providerModel?.phone
                    }
                    else{
                        self.phoneNumber.text = "there no phone number"
                        self.phoneNumber.alpha = 0.3

                    }
                    
                    
                    if  self.providerModel?.phone != nil
                    {
                          self.phoneNumber.text = (self.providerModel?.phone)!
                    }
                    else
                    {
                        self.phoneNumber.text = "there no phone number"

                    }
                    if  self.providerModel?.contacts != nil
                    {
                        if  (self.providerModel?.contacts?.count)! > 0
                        {
                            if (self.providerModel?.contacts![0].email) == nil
                            {
                                self.email.text = "no email"
                                self.email.alpha = 0.3
                            }
                            else{
                             self.email.text =  (self.providerModel?.contacts![0].email)
                            }
                        }
                        else
                        {
                             self.email.text = "no email"
                            self.email.alpha = 0.3
                        }
                    }
                    else
                    {
                        self.email.text = "no email"
                        self.email.alpha = 0.3
                    }
                    if self.providerModel?.webSite != nil
                    {
                        self.website.text = (self.providerModel?.webSite)
                    }
                    else{
                        self.website.text = "there is no website"
                        self.website.alpha = 0.3
                    }
                    
                    if self.providerModel?.images != nil {
                        if self.providerModel?.images?.count == 0 {
                        self.slideShow.isHidden = true
                        }
                        else{
                            var images2: [InputSource] = []

                            for image in (self.providerModel?.images)! {
                                if image.path !=  nil {
                                    let image_path: String = "\(ApiRouts.Web)\(image.path!)"
                                    print("details image paths : \(image_path)")
                                    //print("%%%%%%%%%%%%%%%%%%%% \(image_path)")
                                    if AlamofireSource(urlString: image_path) != nil  {
                                        images2.append(AlamofireSource(urlString: image_path)!)
                                    }
                                }

                            }

                            self.slideShow.setImageInputs(images2)
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProviderViewController.didTap))
                            self.slideShow.addGestureRecognizer(gestureRecognizer)
                        }
                    }

                }

                
                print("after Decoding \(self.providerModel)")
            }
             catch let error {
            }
      }
            
    }
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }

}
