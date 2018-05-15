//
//  GroupChatViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 7.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SocketIO
import SwiftHTTP
import SDWebImage

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
 
    @IBOutlet weak var titleGroup: UILabel!
    @IBAction func sendMessage(_ sender: Any) {
        if (chatFeild?.text)! != ""
        {
            let message = (chatFeild?.text)!
        self.chatFeild?.text = ""
        print("message: \((chatFeild?.text)!)")
        if message != "" {
            let params = ["type":"text","message": message, "sender_id": (MyVriables.currentMember?.id!)!, "chat_type" : "group"
                , "group_id" : (MyVriables.currentGroup?.id!)! , "chat_id" : (MyVriables.currentGroup?.chat?.id)!
                ] as [String : Any]
            print("params: \(params)")
            
            HTTP.POST(ApiRouts.Web + "/api/chats", parameters: params) { response in
                var newMessage :ChatListGroupItem = ChatListGroupItem()
                newMessage.message = message
                newMessage.type = "text"
                newMessage.member_id = MyVriables.currentMember?.id!
                print(newMessage)
                DispatchQueue.main.async {
                    self.messages?.messages?.append(newMessage)
                    self.chatTableView.reloadData()
                    self.scrollToLast()
                }
            }
        }
        }
    }
    @IBOutlet weak var chatFeild: UITextField!
    var chatMessages: [ChatListGroupItem]?
    var messages: ChatGroup?
    var chatsMessages: ChatGroup?
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    
    @IBOutlet weak var keyboardConstraitns: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // like a comment but it isn't one
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
                view.addGestureRecognizer(tap)
        titleGroup.text = (MyVriables.currentGroup?
            .translations![0].title)!
        setSocket()
        chatFeild.autocorrectionType = .no
        chatTableView.tableFooterView = UIView()
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.allowsSelection = false
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        
        editView.layer.shadowOffset = CGSize.zero
        editView.layer.shadowRadius = 0.5
        editView.layer.shadowOffset = CGSize.zero
        editView.layer.shadowRadius = 1
        
        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowOffset = CGSize.zero
        headerView.layer.shadowRadius = 1
       
    }
    
    func setSocket(){
        
        print("----- ABED -----")
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        socket = manager.defaultSocket
        //"group-chat-"+groupId+":chat-message"
        socket!.on(clientEvent: .connect) {data, ack in
        self.socket!.emit("subscribe", "group-chat-\((MyVriables.currentGroup?.id)!)")
        }
        socket!.on("group-chat-\((MyVriables.currentGroup?.id)!):chat-message")
        { data, ack in
            print("onMessageRec: \(data[0])")
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                    var newMessage : ChatListGroupItem = ChatListGroupItem()
                    newMessage.created_at = messageClass["created_at"] as? String
                    newMessage.member_id = messageClass["member_id"] as? Int
                   
                    if let profile_image = data2["profile_image"] as? String {
                        newMessage.profile_image = profile_image
                    }
                    if  messageClass["image_path"] != nil {
                        newMessage.image_path = messageClass["image_path"] as? String
                    }
                    newMessage.message = messageClass["message"] as? String
                    newMessage.type = messageClass["type"] as? String
                    print(newMessage)
                    if (MyVriables.currentMember?.id)! != newMessage.member_id {
                        self.messages?.messages!.append(newMessage)
                        self.chatTableView.reloadData()
                        self.scrollToLast()
                    }
                    else{
                        return
                    }

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
    @objc func keyboardWillShow(notification:NSNotification) {
        //    adjustingHeight(show: true, notification: notification)
        print("in keyboard show")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            keyboardConstraitns.constant = keyboardSize.height + 105
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
            
            keyboardConstraitns.constant = 70
        }

    }
   
    override func viewWillAppear(_ animated: Bool) {
         getGroupHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messages?.messages?.count) != nil {
//           print(self.messages?.messages?.count)
            return (self.messages?.messages?.count)!
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "partnerTextCell", for: indexPath) as! PartnerTextCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "meTextCell", for: indexPath) as! MeTextCell
        let imageMeCell = tableView.dequeueReusableCell(withIdentifier: "imageMeCell", for: indexPath) as! ImageMeCell
          let imagePartnerCell = tableView.dequeueReusableCell(withIdentifier: "imagePartnerCell", for: indexPath) as! ImagePartnerCell
           let filePartnerCell = tableView.dequeueReusableCell(withIdentifier: "partnerFileCell", for: indexPath) as! PartnerFileCell
          let fileMeCell = tableView.dequeueReusableCell(withIdentifier: "meFileCell", for: indexPath) as! MeFileCell
        if self.messages?.messages![indexPath.row].member_id! == MyVriables.currentMember?.id!
        {
            if (self.messages?.messages![indexPath.row].type)! == "text"
            {
                if self.messages?.messages![indexPath.row].message != nil {
                    cell2.textLbl.text = (self.messages?.messages?[indexPath.row].message!)!
                }
                return cell2
            }
            else
            {
                if (self.messages?.messages![indexPath.row].type)! == "image"
                {
                    
                    
                    return imageMeCell
                }
                else
                {
                    return fileMeCell
                }
            }
            
            
        }
        else {
            
            do{
                if self.messages?.messages![indexPath.row].profile_image != nil{
                    if "snapgroup" == (self.messages?.messages![indexPath.row].profile_image)!
                    {
                        cell.partnerProfile.image = UIImage(named: "new logo")
                        imagePartnerCell.partnerImageProfile.image = UIImage(named: "new logo")
                        
                    }
                    else
                    {
                    let urlString = try ApiRouts.Web + (self.messages?.messages![indexPath.row].profile_image)!
                    let url = URL(string: urlString)
                    cell.partnerProfile.sd_setImage(with: url!, completed: nil)
                    imagePartnerCell.partnerImageProfile.sd_setImage(with: url!, completed: nil)
                    }
                    cell.partnerProfile.layer.cornerRadius =  cell.partnerProfile.frame.size.width / 2;
                     cell.partnerProfile.clipsToBounds = true;
                    cell.partnerProfile.layer.borderWidth = 1.0
                     cell.partnerProfile.layer.borderColor = UIColor.gray.cgColor
                    
                    imagePartnerCell.partnerImage.layer.cornerRadius = imagePartnerCell.partnerImage.frame.size.width / 2;
                    imagePartnerCell.partnerImage.clipsToBounds = true;
                    imagePartnerCell.partnerImage.layer.borderWidth = 1.0
                    imagePartnerCell.partnerImage.layer.borderColor = UIColor.gray.cgColor
                }
                else
                {
                    cell.partnerProfile.image = UIImage(named: "default user")
                    imagePartnerCell.partnerImageProfile.image = UIImage(named: "default user")
                }
            }catch let error {
               
            }
            if self.messages?.messages![indexPath.row].type! == "text"
            {
                
                if self.messages?.messages![indexPath.row].sender_name != nil {
                    cell.partnerName.text = (self.messages?.messages?[indexPath.row].sender_name!)!
                }
                if (self.messages?.messages?[indexPath.row].message) != nil {

                    //print(" MESSAGE IS : \((self.messages?.messages?[indexPath.row].message!)!)")
                    cell.textLbl.text = "\((self.messages?.messages?[indexPath.row].message!)!)"
                   
                }
                 return cell
            }
            else
            {
                if self.messages?.messages![indexPath.row].sender_name != nil {
                    imagePartnerCell.partnerName.text = (self.messages?.messages?[indexPath.row].sender_name!)!
                }
                if (self.messages?.messages![indexPath.row].type)! == "image"
                {
                    if (self.messages?.messages![indexPath.row].image_path)! != nil
                    {
                        var urlString: String
                        print("THIS IS   "+"\((self.messages?.messages![indexPath.row].image_path)!)")
                        if (self.messages?.messages![indexPath.row].image_path)!.range(of: "http") != nil{
                            urlString = (self.messages?.messages![indexPath.row].image_path)!
                        }
                        else {
                            urlString = try ApiRouts.Web + (self.messages?.messages![indexPath.row].image_path)! }
                       urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                        let url = URL(string: urlString)
                        if url != nil{
                            imagePartnerCell.partnerImage.sd_setImage(with: url!, completed: nil)}
                    }
                   
                    return imagePartnerCell
                    //imageMeCell.meImage.image = UIImage
                }
                else
                {
                    return filePartnerCell
                }
                
            }
            
           
        }
     
    }
    func getGroupHistory(){
        print(ApiRouts.Web+"/api/chats/messages?chat_id=\((MyVriables.currentGroup?.chat?.id!)!)")
        HTTP.GET(ApiRouts.Web+"/api/chats/messages?chat_id=\((MyVriables.currentGroup?.chat?.id!)!)", parameters: ["hello": "world", "param2": "value2"])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            //print("responseeee "+response.description)
            do{
           self.messages  = try JSONDecoder().decode(ChatGroup.self, from: response.data)
            //print("responseeeeaasd \(self.messages!)")
                DispatchQueue.main.sync {
                    //for index in 1...5 {
                    
                    if self.messages?.messages?.count == 0
                    {
   

                        var groupItem :ChatListGroupItem = ChatListGroupItem()
                        groupItem.sender_name = "Snapgroup"
                        groupItem.member_id = 0
                        groupItem.type = "text"
                        groupItem.profile_image = "snapgroup"
                        groupItem.message = "Welcome to the group chat.Here you can share text messages and images with the rest of the group members."
                        self.messages?.messages?.append(groupItem)
                    }
    
                   // print("chat messsages is :::: \((self.chatMessages?.count)!)")
                    self.chatTableView.reloadData()
                  
                        self.scrollToLast()
                    
                    
                }
            }
            catch {
                
            }
    
            
        }
        
        
    }
    
    func scrollToLast(){
        //        let numberOfSections = self.chatTableView.numberOfSections
        //        let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
        //        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        //        self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        
        if (self.messages?.messages?.count)! > 0 {
            let indexPath = IndexPath(row: (self.messages?.messages?.count)! - 1 , section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
    }

}
