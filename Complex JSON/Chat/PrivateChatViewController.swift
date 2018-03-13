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

struct privateChatMessage: Codable {
    var member_id: Int?
    var message: String?
    var created_at: String?
    var type: String?
    
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


class PrivateChatViewController: UIViewController  , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
  
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var usernamelb: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    var originY : CGFloat?

    @IBOutlet weak var chatTextFeild: UITextField!
    var messageUser: Message?
    var myId: Int?
    var allMessages: [privateChatMessage] = []
    
    @IBAction func onCloseTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseTapped2(_ sender: Any) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        moveTextField(textField, moveDistance: -250, up: true)
    }
   
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        moveTextField(textField, moveDistance: -250, up: false)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if #available(iOS 10.0, *) {
        } else {
            moveTextField(textField, moveDistance: -250, up: false)
            // or use some work around
        }
        textField.resignFirstResponder()
        return true
    }
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSocket()
        self.messageUser = ChatUser.currentUser!
        self.userImage.layer.borderWidth = 0
        self.userImage.layer.masksToBounds = false
        self.userImage.layer.cornerRadius = userImage.frame.height/2
       userImage.clipsToBounds = true
        let urlString = ApiRouts.Web + (self.messageUser?.image_path)!
        let url = URL(string: urlString)
       // self.userImage.downloadedFrom(url: url!, contentMode: .scaleToFill)
        let border = CALayer()
        let width = CGFloat(0.6)
        
      
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
        
        
        print("urllllll: \(url!)")
        userImage.sd_setImage(with: url! , placeholderImage: UIImage(named: "default user"))
        
        self.usernamelb.text = "\((self.messageUser?.opponent_first_name)!) \((self.messageUser?.opponent_last_name)!)"
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
        self.getHistoryConv()
        chatTableView.rowHeight = UITableViewAutomaticDimension

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
        

        
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
   
    
    @objc   func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
    override func viewDidAppear(_ animated: Bool) {
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: (ChatUser.currentUser?.opponent_first_name!)! + " " + (ChatUser.currentUser?.opponent_last_name!)! , style:.plain, target:nil, action:nil)
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
        var urlString = ApiRouts.Web + (ChatUser.currentUser?.image_path)!
        if (ChatUser.currentUser?.image_path)!.contains("http") {
            urlString = (ChatUser.currentUser?.image_path)!
        }
        let url = URL(string: urlString)
        imageView.downloadedFrom(url: url!)
        navigationItem.titleView = imageView
        navigationItem.titleView = imageView
        print("view will appeard \((ChatUser.currentUser?.opponent_first_name!)! + " " + (ChatUser.currentUser?.opponent_last_name!)!)")
        navigationItem.backBarButtonItem?.title = (ChatUser.currentUser?.opponent_first_name!)! + " " + (ChatUser.currentUser?.opponent_last_name!)!
        navigationController?.navigationBar.backItem?.title = (ChatUser.currentUser?.opponent_first_name!)! + " " + (ChatUser.currentUser?.opponent_last_name!)!
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override  func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
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
        var oponent_id =  ChatUser.currentUser?.opponent_id!
        print()
        HTTP.GET("https://dev.snapgroup.co.il/api/privatechat/markread/\(oponent_id!)/\(myId!)") { response in
            print(response.description)
        }
    }
 
    func setSocket(){
       
            print("----- ABED -----")
            var  manager = SocketManager(socketURL: URL(string: "https://dev.snapgroup.co.il:3030/")!, config: [.log(true),.forcePolling(true)])
            socket = manager.defaultSocket
            socket!.on(clientEvent: .connect) {data, ack in
                self.socket!.emit("subscribe", "member-74")
                
            }
            socket!.on("member-74:member-channel") {data, ack in
                if let data2 = data[0] as? Dictionary<String, Any> {
                    if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                       
                            var newMessage :privateChatMessage = privateChatMessage()
                            newMessage.created_at = messageClass["created_at"] as? String
                            newMessage.member_id = messageClass["member_id"] as? Int
                            var oponent_id =  ChatUser.currentUser?.opponent_id!
                        
                        
                            newMessage.message = messageClass["message"] as? String
                            newMessage.type = messageClass["type"] as? String
                            print(newMessage)
                            if oponent_id! == newMessage.member_id {
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
        self.resetMessages()
    }

    @IBAction func sendTapped(_ sender: Any) {
        var oponent_id =  ChatUser.currentUser?.opponent_id!
        print("myId: \(myId!)")
        print("opId: \(oponent_id!)")
        var message = (chatTextFeild?.text)!
        self.chatTextFeild?.text = ""
        print("message: \((chatTextFeild?.text)!)")
        if message != "" {
            let params = ["type":"text","message": message, "sender_id": 74, "receiver_id" : oponent_id!] as [String : Any]
            print("params: \(params)")

            HTTP.POST("https://dev.snapgroup.co.il/api/sendprivatemessage", parameters: params) { response in
                print(params)
                print(response.statusCode)
                var newMessage :privateChatMessage = privateChatMessage()
                newMessage.message = message
                newMessage.type = "text"
                newMessage.member_id = 74
                print(newMessage)
                DispatchQueue.main.async {
                    self.allMessages.append(newMessage)
                    self.chatTableView.reloadData()
                    self.scrollToLast()
                }
              
                

        }
        }
    }
    
    
    // chat send message request
    
    
    
    // chat table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privateCustomCell") as! PrivateChatMessageCelVc
        if allMessages[indexPath.row].member_id == 74 {
            cell.recMessageView.isHidden = true
            cell.sentMessageView.isHidden = false
            cell.sentMessageLbl.text = allMessages[indexPath.row].message!

        } else {
            cell.recMessageView.isHidden = false
            cell.sentMessageView.isHidden = true
            cell.recMessageLbl.text = allMessages[indexPath.row].message!

        }
        cell.selectionStyle = .none
        if (indexPath.row == self.allMessages.count-1) {
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        }
        return cell
    }

    func getHistoryConv(){
        print("\(ApiRouts.HistoryConversation)74/\((messageUser?.opponent_id!)!)")
        HTTP.GET("\(ApiRouts.HistoryConversation)74/\((messageUser?.opponent_id!)!)", parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")

                print("request messages here")

                return //also notify app of failure as needed
            }
            do {
                let  messages = try JSONDecoder().decode([privateChatMessage].self, from: response.data)
                DispatchQueue.main.sync {
                    self.allMessages = messages
                    self.allMessages = self.allMessages.filter({ (message: privateChatMessage) -> Bool in
                        return message.type != "image"
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
