//
//  PrivateChatViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/2/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import SocketIO
import ARSLineProgress
import SwiftEventBus
import Alamofire

struct privateChatMessage: Codable {
    var member_id: Int?
    var message: String?
    var created_at: String?
    var type: String?
    
}
var isChatId: Bool = true

struct PrivateMessages: Codable {
    var messages: PrivateMessagesPages?
}
struct PrivateMessagesPages: Codable {
    var data: [Message]?
    var current_page: Int?
    var last_page: Int?
}
public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}



class PrivateChatViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
    
    @IBOutlet weak var progressStar: UIActivityIndicatorView!
    @IBOutlet weak var keyboardConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageHeader: UIImageView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var nameHeader: UILabel!

    var isHasMore: Bool = true
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var usernamelb: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    var originY : CGFloat?
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var chatTextFeild: UITextField!
    var messageUser: Partner?
    var myId: Int?
    var allMessages: [Message] = []
    var curentPage: Int = 1
    @IBAction func onCloseTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onCloseTapped2(_ sender: Any) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           textField.becomeFirstResponder()
        // moveTextField(textField, moveDistance: -250, up: true)

    }
    
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //  uploadImageProfile(info)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let imageName = "temp.png"
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        print("IMAGEPATHOSH: " + imagePath)
        dismiss(animated: true, completion: nil)
        let imageData = UIImagePNGRepresentation(image)!
        print("AlamoUpload: START")
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        ARSLineProgress.show()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "single_image",fileName: "profile_image.jpg", mimeType: "image/jpg")
            
        },to:"https://api.snapgroup.co.il/api/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/media")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    ARSLineProgress.hide()
                    if let object = response.result.value as? Dictionary<String,AnyObject>{
                        if let imageobj = object["image"] as? Dictionary<String,Any>{
                            if let path = imageobj["path"] as? String{
                                print("DICTIONARY: LEVEL 2")
                                var oponent_id =  ChatUser.currentUser?.id!
                                var image_path = ApiRouts.Web + path
                                let params = ["type":"image","image_path": image_path  , "message": "", "sender_id": (MyVriables.currentMember?.id!)!, "chat_type" : "private", "receiver_id" : oponent_id!] as [String : Any]
                                print("params: \(params)")
                                HTTP.POST(ApiRouts.Web + "/api/chats", parameters: params) { response in
                                    print("send chat: \(response.statusCode)" )
                                    var newMessage :Message = Message()
                                    newMessage.message = ""
                                    newMessage.type = "image"
                                    newMessage.image_path = image_path
                                    newMessage.member_id = MyVriables.currentMember?.id!
                                    print(newMessage)
                                    do{
                                        DispatchQueue.global().async(execute: {
                                            DispatchQueue.main.async {
                                                self.dismissKeyboard()
                                                self.allMessages.append(newMessage)
                                                self.chatTableView.reloadData()
                                                self.scrollToLast()
                                            }
                                        })
                                        
                                    }catch {}
                                }
                            }
                            
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        
        
    }
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        //  moveTextField(textField, moveDistance: -250, up: false)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //        if #available(iOS 10.0, *) {
        //        } else {
        //            moveTextField(textField, moveDistance: -250, up: false)
        //            // or use some work around
        //        }
        //        textField.resignFirstResponder()
        if textField.text == "" {
            dismissKeyboard()
        }else {
            sendMessage()
            
        }
        return true
    }
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        
        if up {
            //            self.chatTableView.topAnchor.constraint(equalTo: (view.superview?.topAnchor)!, constant: 300how do).isActive = true
        }else {
            self.chatTableView.topAnchor.constraint(equalTo: (view.superview?.topAnchor)!, constant: 0).isActive = true
        }
        UIView.commitAnimations()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    chatTableView.scroll(to: .top, animated: true)
        SwiftEventBus.onMainThread(self, name: "refresh-files_upload") { result in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        backView.addTapGestureRecognizer {
            self.navigationController?.popViewController(animated: true)
        }
        setSocket()
        print("chat id: \(ChatUser.ChatId)")
        self.messageUser = ChatUser.currentUser!
        self.userImage.layer.borderWidth = 0
        chatTextFeild.autocorrectionType = .no
        self.userImage.layer.masksToBounds = false
        self.userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        imagePicker.delegate = self
        
        
        // self.userImage.downloadedFrom(url: url!, contentMode: .scaleToFill)
        let border = CALayer()
        let width = CGFloat(0.6)
        //        if #available(iOS 10, *) {
        //            // Disables the password autoFill accessory view.
        //            chatTextFeild.textContentType = UITextContentType("")
        //        }
        
        
        if #available(iOS 11.0, *) {
            border.borderColor = UIColor(named: "Primary")?.cgColor
        } else {
            // Fallback on earlier versions
            border.borderColor = UIColor(rgb: 0xC1B46A).cgColor
        }
        
        border.frame = CGRect(x: 0, y: self.chatTextFeild.frame.size.height - width, width:  self.chatTextFeild.frame.size.width, height: self.chatTextFeild.frame.size.height)
        
        border.borderWidth = width
        self.chatTextFeild.layer.addSublayer(border)
        self.chatTextFeild.layer.masksToBounds = true
        
        
        
        if self.messageUser?.profile_image != nil {
            let urlString = ApiRouts.Web + (self.messageUser?.profile_image)!
            let url = URL(string: urlString)
            userImage.sd_setImage(with: url! , placeholderImage: UIImage(named: "default user"))
        }else {
            
            userImage.image = UIImage(named: "default user")
        }
        self.usernamelb.text = "\((self.messageUser?.first_name)!) \((self.messageUser?.last_name)!)"
        self.chatTableView.dataSource = self
        chatTableView.delegate = self
        if #available(iOS 11.0, *) {
            self.chatTableView.separatorColor = UIColor(named: "clearColor")
        } else {
            // Fallback on earlier versions
        }
        self.chatTableView.separatorStyle = .none
        
        myId = UserDefaults.standard.integer(forKey: "member_id")
        originY = self.view.frame.origin.y
        print("My chat id is = \(isChatId)")
        if isChatId {
            self.getHistoryConv(isViaChatId: true, page: self.curentPage, isFirstTime: true)
        }else {
            isChatId = true
            self.getHistoryConv(isViaChatId: false, page: self.curentPage, isFirstTime: true)
        }
        //     chatTableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //
        //        view.addGestureRecognizer(tap)
        
        
        
    }
    
    
    @IBAction func attachImageTapped(_ sender: Any) {
        dismissKeyboard()
        if  (MyVriables.currentMember?.gdpr?.files_upload)! == true {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }else
        {
            var gdprObkectas : GdprObject = GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false, parmter: "files_upload", image: "In order to use the files tools, please approve the files usage:")
            MyVriables.enableGdpr = gdprObkectas
            self.performSegue(withIdentifier: "showEnableDocuments", sender: self)
        }
        
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        //    adjustingHeight(show: true, notification: notification)
        print("in keyboard show")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            keyboardConstraints.constant = keyboardSize.height + 105
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.scrollToLast()
            }
        }
        // show keyboard hide
        
        
    }
    
    
    
    @objc   func keyboardWillHide(notification:NSNotification) {
        //   adjustingHeight(show: false, notification: notification)
        print("in keyboard hide")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.keyboardConstraints.constant = 70
        }
        
    }
    var topVisibleIndexPath:IndexPath? = nil
    var isLoading: Bool = false
    var isFirstTime: Bool = true
    var scrollPostion: CGFloat?
    var randomMessages = ["nkbsdkajs hd","askdhh1123","123","jfd111","njfdvb3","8854sda","114345675789","jjjjjjj","9998766","askdhh1123","123"]

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstTime {
            return
        }
        
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
        }else {
        if self.allMessages.count > 0 {
        topVisibleIndexPath = self.chatTableView.indexPathsForVisibleRows![0]
        }
        }
        scrollPostion = chatTableView.contentOffset.y
        if topVisibleIndexPath?.row == 0 && isHasMore {
            if !isLoading {
                print("TESTTEST- load more data .. ")
                isLoading = true
                print("TESTTEST- load more data .. ")
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                // HERE LOAD NEW MESSAGES ...
                    var savedIndex = tableView.indexPathsForVisibleRows?.first
                    let indexPathOfFirstRow = NSIndexPath(row: 0, section: 0)
                    self.progressStar.isHidden = false
                    if isChatId {
                        self.getHistoryConv(isViaChatId: true, page: self.curentPage, isFirstTime: false)
                    }else {
                        isChatId = true
                        self.getHistoryConv(isViaChatId: false, page: self.curentPage, isFirstTime: false)
                    }                    //self.appendCells()
                    
                
                
                if self.allMessages.count > 0 {
//                    let indexPath = IndexPath(row: (self.chatTableView.indexPathsForVisibleRows![0].row)+2 , section: 0)
//                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }

                    
                // FINISH LOAD NEW ITMES
                
            
            }
        }
        }
        
        
    }
    
    private func appendCells() {
       
        var initialOffset = self.chatTableView.contentOffset.y
        var newMessage : Message = Message()
        newMessage.created_at = "2018-04-09 19:23:42"
        newMessage.member_id = 74
        newMessage.type = "text"
        let number = Int(arc4random_uniform(UInt32(10)) + UInt32(0));
        newMessage.message = self.randomMessages[number]
        self.allMessages.insert(newMessage, at: 0)
         self.allMessages.insert(newMessage, at: 0)
         self.allMessages.insert(newMessage, at: 0)
         self.allMessages.insert(newMessage, at: 0)
         self.allMessages.insert(newMessage, at: 0)
        self.chatTableView.reloadData()
        //@numberOfCellsAdded: number of items added at top of the table
//        self.chatTableView.scrollToRowAtIndexPath(NSIndexPath(row: numberOfCellsAdded, section: 0), atScrollPosition: .Top, animated: false)
        self.chatTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: false)
        self.chatTableView.contentOffset.y += initialOffset
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: (ChatUser.currentUser?.first_name!)! + " " + (ChatUser.currentUser?.last_name!)! , style:.plain, target:nil, action:nil)
        //        navigationController?.navigationBar.shadowImage = .none
        //        let nav = self.navigationController?.navigationBar
        //
        //        // 2
        //
        //        nav?.backgroundColor = UIColor.white
        //        // 3
        //        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        //        imageView.contentMode = .scaleAspectFit
        //
        //
        //
        //        // 4
        //        let image = UIImage(named: "default user")
        //        imageView.image = image
        //
        //        // 5
        //        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        //
        //
        //      //  navigationItem.titleView = label
        ////        navigationController?.navigationBar.backItem?.title = ""
        ////        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "Primary")
        ////        navigationItem.backBarButtonItem?.title  = (ChatUser.currentUser?.opponent_first_name!)! + " " + (ChatUser.currentUser?.opponent_last_name!)!
        //        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
       // headerView.
      
        
        headerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        headerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        headerView.layer.shadowOpacity = 1.0
        headerView.layer.shadowRadius = 0.0
        headerView.layer.masksToBounds = false
        headerView.layer.cornerRadius = 4.0
        print("Navigation-Test: in viewwillappear")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.shadowImage = .none
        let nav = self.navigationController?.navigationBar
        nav?.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 0
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 1
        
        
        
        if #available(iOS 11.0, *) {
            imageView.layer.borderColor = UIColor(named: "Primary")?.cgColor
        } else {
            // Fallback on earlier versions
            imageView.layer.borderColor =  Colors.PrimaryColor.cgColor
        }
        imageView.clipsToBounds = true
        if ChatUser.currentUser?.profile_image != nil && (ChatUser.currentUser?.profile_image)! != "" {
            var urlString = ApiRouts.Web + (ChatUser.currentUser?.profile_image)!
            if (ChatUser.currentUser?.profile_image)!.contains("http") {
                urlString = (ChatUser.currentUser?.profile_image)!
            }
            let url = URL(string: urlString)
            imageView.downloadedFrom(url: url!)
            profileImageHeader.downloadedFrom(url: url!)
            profileImageHeader.contentMode = .scaleAspectFill
        }else {
            //    profileImageHeader profileImageHeader
            imageView.layer.borderColor =  UIColor.white.cgColor
            imageView.image =  UIImage(named: "default member 2")

            profileImageHeader.image =  UIImage(named: "default member 2")
        }
        nameHeader.text = (ChatUser.currentUser?.first_name!)! + " " + (ChatUser.currentUser?.last_name!)!
        navigationItem.titleView = imageView
        navigationItem.titleView = imageView
        print("view will appeard \((ChatUser.currentUser?.first_name!)! + " " + (ChatUser.currentUser?.last_name!)!)")
        navigationItem.backBarButtonItem?.title = (ChatUser.currentUser?.first_name!)! + " " + (ChatUser.currentUser?.last_name!)!
        navigationController?.navigationBar.backItem?.title = (ChatUser.currentUser?.first_name!)! + " " + (ChatUser.currentUser?.last_name!)!
        if #available(iOS 11.0, *) {
            navigationItem.backBarButtonItem?.tintColor = UIColor(named: "Primary")
            navigationController?.navigationBar.tintColor = UIColor(named: "Primary")
            
        } else {
            //
            // Fallback on earlier versions
            navigationItem.backBarButtonItem?.tintColor = Colors.PrimaryColor
            navigationController?.navigationBar.tintColor = Colors.PrimaryColor
            
        }
        
        
        //
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.resetMessages()

        markConvRead()
         self.socket!.disconnect()
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override  func dismissKeyboard() {
        print("IMAGETAPPED - from dismissKeyboard")
        view.endEditing(true)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        print("adjustingHeight")
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue)!
        // 3
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 4
        let changeInHeight = (keyboardFrame.height + 30) * (show ? 1 : -1)
        //5
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
        
        
    }
    
    func resetMessages(){
        print("------ IN RESET MESSAGES ----- ")
        var oponent_id =  ChatUser.currentUser?.id!
        print()
        HTTP.GET("https://dev.snapgroup.co.il/api/privatechat/markread/\(oponent_id!)/\(myId!)") { response in
            print(response.description)
        }
    }
    func markConvRead(){
        let params = ["member_id": MyVriables.currentMember?.id!] as [String : Any]
        print("params: \(params)")
        if ChatUser.ChatId != nil {
            HTTP.POST(ApiRouts.Web + "/api/chats/\(ChatUser.ChatId!)?member_id=\((MyVriables.currentMember?.id)!)", parameters: params) { response in
                print("mark conv: \(response.description)" )
               
            }
        }
    }
    func setSocket(){
        
        print("----- ABED -----")
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        socket = manager.defaultSocket
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "member-\((MyVriables.currentMember?.id!)!)")
        }
        socket!.on("member-\((MyVriables.currentMember?.id!)!):member-channel") {data, ack in
            print("onMessageRec: \(data[0])")
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                    
                    var newMessage : Message = Message()
                    newMessage.created_at = messageClass["created_at"] as? String
                    newMessage.member_id = messageClass["member_id"] as? Int
                    var oponent_id =  ChatUser.currentUser?.id!
                    
                    
                    newMessage.message = messageClass["message"] as? String
                    newMessage.type = messageClass["type"] as? String
                    if newMessage.type == "image"
                    {
                        var path = messageClass["image_path"] as? String
                        newMessage.image_path = path!
                    }
                    print(newMessage)
                    if oponent_id! == newMessage.member_id {
                        print("MESSAGECLASS--\(newMessage.image_path)")
                        
                        self.allMessages.append(newMessage)
                        self.chatTableView.reloadData()
                        self.scrollToLast()
                    }
                    else{
                        return
                    }
                    
                    //  self.allMessages.append(newMessage)
                    //    self.chatTableView.reloadData()
                    print(" good")
                    
                    
                    
                }
            }
            
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
        
        self.socketManager = manager
        self.socket!.connect()
        
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.resetMessages( )
        self.markConvRead()
        
    }
    
    fileprivate func sendMessage() {
        var oponent_id =  ChatUser.currentUser?.id!
        print("myId: \(myId!)")
        print("opId: \(oponent_id!)")
        var message = (chatTextFeild?.text)!
        self.chatTextFeild?.text = ""
        print("message: \((chatTextFeild?.text)!)")
        if message != "" {
            let params = ["type":"text","message": message, "sender_id": (MyVriables.currentMember?.id!)!, "chat_type" : "private", "receiver_id" : oponent_id!] as [String : Any]
            print("params: \(params)")
            
            HTTP.POST(ApiRouts.Web + "/api/chats", parameters: params) { response in
                print("send chat: \(response.statusCode)" )
                var newMessage :Message = Message()
                newMessage.message = message
                newMessage.type = "text"
                newMessage.member_id = MyVriables.currentMember?.id!
                print(newMessage)
                DispatchQueue.main.async {
                    self.allMessages.append(newMessage)
                    self.chatTableView.reloadData()
                    self.scrollToLast()
                }
                
                
                
            }
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        sendMessage()
    }
    
    
    // chat send message request
    
    
    
    // chat table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMessages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("IMAGETAPPED: yes")
        
        if allMessages[indexPath.row].type == "image"{
            print("IMAGETAPPED: yes")
            MyVriables.imageUrl = (allMessages[indexPath.row].image_path)!
            performSegue(withIdentifier: "showImageSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allMessages[indexPath.row].member_id == MyVriables.currentMember?.id! {
            //imageMeCell

            if allMessages[indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageMeCell") as! ImageMeTableViewCell
                let urlString = (allMessages[indexPath.row].image_path)!
                let url = URL(string: urlString)
                
                print("--PRIVATECHAT \(urlString)")
                
                cell.meImageView.sd_setImage(with: url! , placeholderImage: UIImage(named: "Group Placeholder"))
                
                
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "privateCustomCell") as! PrivateChatMessageCelVc
                cell.sentMessageLbl.text = allMessages[indexPath.row].message!
                cell.selectionStyle = .none
                if (indexPath.row == self.allMessages.count-1) {
                    cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                }
                return cell
            }
            
        } else {
            if allMessages[indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "partnerImageCell") as! ImagePartnerTableViewCell
                let urlString =  (allMessages[indexPath.row].image_path)!
                let url = URL(string: urlString)
                print("--PRIVATECHAT \(urlString)")
                
                cell.partnerImageview.sd_setImage(with: url! , placeholderImage: UIImage(named: "Group Placeholder"))
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "partnerCell") as! PartnerViewCell
                cell.recMessageLbl.text = allMessages[indexPath.row].message!
                cell.selectionStyle = .none
                if (indexPath.row == self.allMessages.count-1) {
                    cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                }
                return cell
            }
            
        }
        
    }
    func prepareReloadData() {
        let previousContentHeight = chatTableView.contentSize.height
        let previousContentOffset = chatTableView.contentOffset.y
        chatTableView.reloadData()
        let currentContentOffset = chatTableView.contentSize.height - previousContentHeight + previousContentOffset
        chatTableView.contentOffset = CGPoint(x: 0, y: currentContentOffset)
    }
    func getHistoryConv(isViaChatId: Bool, page: Int, isFirstTime: Bool){

        var urlString = ""
       
        if isViaChatId {
            if ChatUser.ChatId != nil
            {
              urlString = ApiRouts.Web + "/api/chats/messages?chat_id=\((ChatUser.ChatId!))&page=\(self.curentPage)"
            }
            
        }else {
            urlString = ApiRouts.Web + "/api/chats/messages?member_id=\((MyVriables.currentMember?.id!)!)&partner_id=\((ChatUser.currentUser?.id!)!)&page=\(self.curentPage)"
        }
         print("CHAT URL IS = \(urlString)")
        HTTP.GET(urlString, parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                self.progressStar.isHidden = true
                print("request messages here")
                
                return //also notify app of failure as needed
            }
            do {
                let  messages = try JSONDecoder().decode(PrivateMessages.self, from: response.data)
                DispatchQueue.main.sync {
                   

                    DispatchQueue.main.async {
                        
                        
                        print("Current page1 = \((messages.messages?.current_page))")
                        var current_Page1 : Int = (messages.messages?.current_page)!
                        var last_Page1 : Int = (messages.messages?.last_page)!
                        if current_Page1 > last_Page1
                        {
                            self.isHasMore = false
                        }
                        self.curentPage = (messages.messages?.current_page!)! + 1
                        if isFirstTime{
                        self.allMessages = (messages.messages?.data!)!
                            self.allMessages.reverse()
                        self.chatTableView.reloadData()
                        self.scrollToLast()
                        }else
                        {
                            var appenArray = (messages.messages?.data!)!
                            appenArray.reverse()
                            self.allMessages.insert(contentsOf: appenArray, at: 0)
                            var initialOffset = self.chatTableView.contentOffset.y
                            self.chatTableView.reloadData()
                            var indexScrollTo = ((messages.messages?.data!)!.count) + 1
                            print("Scroll to \(indexScrollTo)")
                            self.chatTableView.scrollToRow(at: IndexPath(row: ((messages.messages?.data!)!.count), section: 0), at: .top, animated: false)
                            self.chatTableView.contentOffset.y += initialOffset
                        }
                        
                        self.topVisibleIndexPath = self.chatTableView.indexPathsForVisibleRows![0]
                         self.isLoading = false
                         self.progressStar.isHidden = true
                   
                    }
                    
                    
                    
                    
                    
                    
                }
            }
            catch let error {
                print(error)
                
            }
            //    print("opt finished: \(response.description)")
        }
        
    }
    
    
    
    
    @IBAction func clickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollToLast(){
        //        let numberOfSections = self.chatTableView.numberOfSections
        //        let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
        //        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        //        self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        
        if allMessages.count > 0 {
            let indexPath = IndexPath(row: allMessages.count - 1 , section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        isFirstTime = false
        
    }
    
    
}
extension UITableView {
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}


