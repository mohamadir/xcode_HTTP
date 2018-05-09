//
//  AddReviewViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 9.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController,UITextViewDelegate {

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
        addComment.textColor == UIColor.lightGray
       
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
            dismiss(animated: true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
