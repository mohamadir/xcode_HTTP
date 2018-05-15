//
//  AddReviewViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 9.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus
import SwiftHTTP

class AddReviewViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var addComment: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.layer.borderWidth = 2
        viewModel.layer.borderColor = UIColor.gray.cgColor
        viewModel.layer.shadowColor = UIColor.black.cgColor
        viewModel.layer.shadowOpacity = 5
        viewModel.layer.shadowOffset = CGSize.zero
        viewModel.layer.shadowRadius = 10
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        addComment.layer.borderWidth = 0.5
        addComment.layer.borderColor = borderColor.cgColor
        addComment.layer.cornerRadius = 5.0
       
        addComment.delegate = self
        addComment.text = "Write a comment"
        addComment.textColor = UIColor.lightGray
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        viewModel.addGestureRecognizer(tap)
        
      

        // Do any additional setup after loading the view.
    }
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Write a comment" {
            textView.text = nil
              textView.textColor = UIColor.black
        }
    }
    
    @IBAction func onClickSubmit(_ sender: Any) {
        if addComment.text != "" && addComment.text != "Write a comment"
        {
            addCommentFunc()
        }
     
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            DispatchQueue.main.async {
                textView.text = "Write a comment"
                textView.textColor = UIColor.lightGray
            }
        }
    }
    @IBOutlet weak var viewModel: UIView!
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        
         dismiss(animated: true, completion: nil)
    }
    //ProviderInfo.model_type
    //ProviderInfo.model_id
    func addCommentFunc(){
        let perameters:  [String : Any] = ["model_type": ProviderInfo.model_type!, "model_id": ProviderInfo.model_id!
        , "reviewer_id": (MyVriables.currentMember?.id!)!
            , "rating": "\(self.seekBar.value)"
        , "review": addComment.text!]
        print(perameters)
        
        HTTP.POST(ApiRouts.Web+"/api/ratings", parameters: perameters)
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("\(response.data)")
            DispatchQueue.main.sync {
                SwiftEventBus.post("newComment")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }

}
