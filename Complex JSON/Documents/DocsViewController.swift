//
//  DocsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/16/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import ARSLineProgress

struct ImageServer: Codable {
    var image: GroupImage?
}
class DocsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }

    @IBAction func Pick(_ sender: Any) {
       let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .savedPhotosAlbum
        present(controller, animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
        dismiss(animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image: URL?
        if #available(iOS 11.0, *) {
            image = info[UIImagePickerControllerImageURL] as! URL
        } else {
            // Fallback on earlier versions
            image = info[UIImagePickerControllerReferenceURL] as! URL

        }
        
        ARSLineProgress.show()
        
        dismiss(animated: true, completion: nil)
        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: (image?.absoluteURL)!)]) { response in
            ARSLineProgress.hide()
            
            let data = response.data
            do {
                let  image2 = try JSONDecoder().decode(ImageServer.self, from: data)
                print(image2.image?.path)
            }catch let error {
                print(error)
            }
            print(response.data)
            print(response.data.description)
            if response.error != nil {
                print(response.error)
            }
            //do things...
           
        }

    }
    
}
