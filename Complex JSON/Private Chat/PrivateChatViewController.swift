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
struct privateChatMessage: Codable {
    var member_id: Int?
    var message: String?
    var created_at: String?
    var type: String?
    
}
var isChatId: Bool = true

struct PrivateMessages: Codable {
    var messages: [Message]?
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

    @IBOutlet weak var keyboardConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var chatTableView: UITableView!

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

    @IBAction func onCloseTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func onCloseTapped2(_ sender: Any) {
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
     //   textField.becomeFirstResponder()
       // moveTextField(textField, moveDistance: -250, up: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image: URL
        print(info)
        if #available(iOS 11.0, *) {
            image = info[UIImagePickerControllerImageURL] as! URL
        } else {
            // Fallback on earlier versions
            image = info[UIImagePickerControllerReferenceURL] as! URL

        }
        ARSLineProgress.show()
        print("image ref: \(image)" )

        dismiss(animated: true, completion: nil)
        print("UPLOADIMAGE- url - "+"https://api.snapgroup.co.il/api/upload_single_image/Member/\(MyVriables.currentMember?.id!)/media")
        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/media", parameters: ["single_image": Upload(fileUrl: image.absoluteURL)]) { response in

            ARSLineProgress.hide()
            if response.error != nil {
                print(response.error)
                return
            }
            let data = response.data
            do {
                if response.error != nil {
                    print("response is : ERROR \(response.error)")

                    return
                }
                let  image2 = try JSONDecoder().decode(ImageServer.self, from: data)
                    print("image response is : \(image2.image?.path)")
                    print(response.description)
                // send image here
                var oponent_id =  ChatUser.currentUser?.id!
                var image_path = ApiRouts.Web +  (image2.image?.path!)!
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
                    DispatchQueue.main.async {
                        self.dismissKeyboard()
                        self.allMessages.append(newMessage)
                        self.chatTableView.reloadData()
                        self.scrollToLast()
                    }
                }

            }catch let error {
                print(error)
            }
            print(response.data)
            print(response.data.description)



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
        if isChatId {
            self.getHistoryConv(isViaChatId: true)
        }else {
            isChatId = true
            self.getHistoryConv(isViaChatId: false)
        }
   //     chatTableView.rowHeight = UITableViewAutomaticDimension

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//
//        view.addGestureRecognizer(tap)



    }
    
    
    @IBAction func attachImageTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        dismissKeyboard()
        
        present(imagePicker, animated: true, completion: nil)
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
         self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        if ChatUser.currentUser?.profile_image != nil {
            var urlString = ApiRouts.Web + (ChatUser.currentUser?.profile_image)!
            if (ChatUser.currentUser?.profile_image)!.contains("http") {
                urlString = (ChatUser.currentUser?.profile_image)!
            }
            let url = URL(string: urlString)
            imageView.downloadedFrom(url: url!)
        }else {
            imageView.layer.borderColor =  UIColor.white.cgColor
            imageView.image =  UIImage(named: "default user")
        }
        
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        HTTP.POST(ApiRouts.Web + "/api/chats/\(ChatUser.ChatId!)", parameters: params) { response in
            print("mark conv: \(response.description)" )
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

    func getHistoryConv(isViaChatId: Bool){
        print("\(ApiRouts.HistoryConversation)74/\((messageUser?.id!)!)")
        var urlString = ""
        
        if isViaChatId {
            urlString = ApiRouts.Web + "/api/chats/messages?chat_id=\((ChatUser.ChatId!))"
        }else {
            urlString = ApiRouts.Web + "/api/chats/messages?member_id=\((MyVriables.currentMember?.id!)!)&partner_id=\((ChatUser.currentUser?.id!)!)"
        }
        HTTP.GET(urlString, parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")

                print("request messages here")

                return //also notify app of failure as needed
            }
            do {
                let  messages = try JSONDecoder().decode(PrivateMessages.self, from: response.data)
                DispatchQueue.main.sync {
                    self.allMessages = messages.messages!
                    self.allMessages = self.allMessages.filter({ (message: Message) -> Bool in
                        return  true
                    })
                    self.chatTableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        self.scrollToLast()
                    }

                }
            }
            catch let error {
                print(error)

            }
        //    print("opt finished: \(response.description)")
        }

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

    }


}


