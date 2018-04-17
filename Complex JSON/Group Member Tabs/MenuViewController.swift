//
//  MenuViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/26/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
class MenuViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var groupNameLbl: UILabel!
    var singleGroup: TourGroup?
    var countdownTimer: Timer!
    var totalTime = 60
    let date = Date()
    let formatter = DateFormatter()
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var mapsView: UIControl!
    
    @IBOutlet weak var leaderView: UIControl!
    @IBOutlet weak var votesView: UIControl!
    @IBOutlet weak var membersView: UIControl!
    @IBOutlet weak var docsView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var itineraryView: UIView!
    @IBOutlet weak var checkListView: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.singleGroup  = MyVriables.currentGroup!
        if singleGroup?.translations?.count == 0 {
            self.groupNameLbl.text = singleGroup?.title
        }
        else {
            self.groupNameLbl.text = singleGroup?.translations?[0].title

        }
        self.groupNameLbl.numberOfLines = 0
        self.groupNameLbl.lineBreakMode = .byWordWrapping
     //   self.membersTp.addTarget(self, action: #selector(membersClick), for: .touchUpInside)
        membersView.addTapGestureRecognizer {
               self.performSegue(withIdentifier: "showMembers", sender: self)
        }
        votesView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showScroll", sender: self)
        }
        docsView.addTapGestureRecognizer {
            print("hi")
            self.uploadImageToServer()
           
           // self.uploadImageToServer()
        }
        mapsView.addTapGestureRecognizer {
             self.performSegue(withIdentifier: "showTest", sender: self)
        }
        servicesView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showServices", sender: self)
        }
        itineraryView.addTapGestureRecognizer {
             self.performSegue(withIdentifier: "showPlanSegue", sender: self)
        }
        docsView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showDocs", sender: self)

        }
        checkListView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showCheckList", sender: self)

        }
        leaderView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showLeaderSegue", sender: self)

        }
        
        startTimer()
        // Do any additional setup after loading the view.
    }
    func uploadImageToServer(){
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        
//        let fileUrl = URL(fileURLWithPath: "/Users/snapmac/Downloads/leader.png")
//        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: fileUrl)]) { response in
//
//            print(response.description)
//            //do things...
//        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //var image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        var urlosh: URL = (info[UIImagePickerControllerReferenceURL] as! URL)
        let imageName = urlosh.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as! String
        let localPath = documentDirectory.appending(imageName)
        
        let fileUrl = URL(fileURLWithPath: localPath)

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = UIImagePNGRepresentation(image)
            do{
                try  data?.write(to: fileUrl, options: .atomic)
                print("success to data")
                
            }catch {
                print("error")
            }
            
            let imageData = NSData(contentsOfFile: localPath)!
            let photoURL = URL(fileURLWithPath: localPath)
            
            let imageWithData = UIImage(data: imageData as Data)!
            // self.uploadImage(image: image)
            print(photoURL)
            print("before post ")
            HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: photoURL)]) { response in
                print("during post ")
    
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                print(response)
                //do things...
    
            
        }
    
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func membersClick(){
        print("tapped")
        
    }
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        counterLbl.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
//    @IBAction func goToMembers(_ sender: Any) {
//        print("pressed")
//        performSegue(withIdentifier: "showMembers", sender: self)
//
//    }
 
    
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func uploadImage(image: UIImage)
    {
        let imageData = UIImageJPEGRepresentation(image, 1)

        if imageData == nil { return }
        print(imageData)
    }
    
    
    

}
