//
//  GroupViewController.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import Auk
import UserNotifications
import SocketIO
import SwiftHTTP
import ImageSlideshow
import Alamofire
import AlamofireImage

public extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}



class GroupViewController: UIViewController   , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var pageViewController: UIPageViewController!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    var res: CFRunLoop?
     var socket: SocketIOClient?
    
    let images = ["new logo","calendar"]
    
    var singleGroup: TourGroup?
    var groupImages: [GroupImage] = []
    
    @IBAction func uploadImage(_ sender: Any) {
        pickImage()
    }
    
    
    func pickImage(){
        var myController = UIImagePickerController()
        myController.delegate = self
        myController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(myController, animated: true, completion: nil)
        
    }
    
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage

       // let path: URL = (info[UIImagePickerControllerReferenceURL] as? URL)!
            if let img : UIImage = imageView.image! as UIImage{
                let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("image.JPG")
                let imageData: NSData = UIImagePNGRepresentation(img)! as NSData
                imageData.write(toFile: path as String, atomically: true)
                
                // once the image is saved we can use the path to create a local fileurl
                upImage(url: URL(string: path)!)
            }
    
    
//    print("pathosh= \(path)")
//        upImage(url: path)
    
        //        saveImage(image: image) { (error) in
//            print(error)
//        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func saveImage(image: UIImage, completion: @escaping (Error?) -> ()) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(path:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    
    @objc private func image(path: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        debugPrint(path) // That's the path you want
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpNotifications()
     //   setUpSocket()
        
//        scrollView.auk.show(url: "https://www.elastic.co/assets/bltada7771f270d08f6/enhanced-buzz-1492-1379411828-15.jpg")
//        scrollView.auk.show(url: "https://www.elastic.co/assets/bltada7771f270d08f6/enhanced-buzz-1492-1379411828-15.jpg")
        let string = UserDefaults.standard.object(forKey: "title")
        let groupRequest = Main()
        groupRequest.getGroupImages(id:( singleGroup?.id)!){ (output) in
            self.groupImages = output!
            var images2: [InputSource]?
                DispatchQueue.main.async {
                 //   var images2: [InputSource]?
                        for image in self.groupImages {
                            
                            images2?.append(AlamofireSource(urlString: "\(ApiRouts.Media)\((image.path)!)")!)
                           // self.slideShow.setImageInputs(<#T##inputs: [InputSource]##[InputSource]#>)
                  //  self.scrollView.auk.show(url: "https://api.snapgroup.co.il\((image.path)!)")
                }
                    self.slideShow.setImageInputs(images2!)
                    
                    
               
            }
            print("===== MOODY \(self.groupImages)")
            
        }
        print(string)
        self.titleLabel.text = singleGroup?.title
        let urlString = "https://api.snapgroup.co.il" + (singleGroup?.image)!
        let url = URL(string: urlString)
      //  imageView.downloadedFrom(url: url!)

        // Do any additional setup after loading the view.
    }

    func setUpSocket(){
        print("----- ABED -----")
        let manager = SocketManager(socketURL: URL(string: "\(ApiRouts.ChatServer)")!, config: [.log(true),.forcePolling(true)])
        
        socket!.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket!.emit("subscribe", "member-74")
            
            
        }
        socket!.on("member-74:member-channel") {data , ack in
            print(data)
            
        }
        socket!.onAny { (socEvent) in
            
            
            if let status =  socEvent.items as? [SocketIOStatus] {
                if let first = status.first {
                    switch first {
                    case .connected:
                        print("Socket: connected")
                        break
                        
                    case .disconnected:
                        print("Socket: disconnected")
                        break
                    case .notConnected:
                        print("Socket: notConnected")
                        break
                    case .connecting:
                        print("Socket: connecting")
                        break
                    default :
                        print("NOTHING")
                        break
                    }
                }
            }
        }
        self.socket!.connect()
    }
    
    func upImage(url: URL){
        print("the url is === \(url)")
//        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: url)]) { response in
//
//            print(response.error)
//            //do things...
//        }
    }
    @IBAction func notifyPressed(_ sender: Any) {
        
        
      
//        HTTP.GET("https://api.snapgroup.co.il/api/groups/24/images") { response in
//            if let err = response.error {
//                print("error: \(err.localizedDescription)")
//                return //also notify app of failure as needed
//            }
//
//            do{
//                let  images = try JSONDecoder().decode([GroupImage].self, from: response.data)
//               print("imagess= \(images)")
//            }
//            catch let error {
//                print(error)
//            }
//            //print("data is: \(response.data)") access the response of the data with response.data
//        }
        
//        timednotifications(inSeconds: 3) { (success) in
//            if success {
//                print("Successfully notified")
//            }
//        }
        
        
    }
//
//    func timednotifications(inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) ->()){
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
//        let content = UNMutableNotificationContent()
//        content.title = "Snapgroup Notifications"
//        content.subtitle = "test notification"
//        content.body = "kljdsfgdkjgf sdfj slkj asdflkjsd fkjsf "
//
//        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if error != nil {
//                completion(false)
//
//            } else{
//                completion(true)
//            }
//        }
//    }
//
//    func setUpNotifications(){
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
//            if error != nil {
//                print("UnSuccessful")
//            }
//            else{
//                print("SUCCESS")
//            }
//
//        }
//    }

    
   
}
