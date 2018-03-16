//
//  DocsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/16/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
class DocsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }

    @IBAction func Pick(_ sender: Any) {
       let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
        dismiss(animated: true, completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerImageURL] as! URL
        
        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: image.absoluteURL)]) { response in
            
            
            if let data2 = response.data as? Dictionary<String, Any> {
                if let messageClass = data2["image"] as? Dictionary<String, Any> {
                    print(messageClass)
                    print(messageClass["path"]!)
                }
            }
            
            print(response.description)
            print(response.data.description)
            if response.error != nil {
                print(response.error)
            }
            //do things...
           
        }
        dismiss(animated: true, completion: nil)

    }
    
}
