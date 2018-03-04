//
//  ChatViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/26/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SocketIO
import SwiftHTTP
import SDWebImage



struct Message: Codable{
    var message: String?
    var sender_id: Int?
    var sender_first_name: String?
    var sender_last_name: String?
    var image_path: String?
    var read: Int?
    var total_unread_messages: Int?
    
   // var messageClass: MessageClass?
}

//struct MessageClass{
//    var created_at: String?
//
//
//}

struct ChatUser {
    static var currentUser: Message?
    
    
}
class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTableView: UITableView!
    var socket: SocketIOClient?
    var messages: [Message]? = []
    var socketManager : SocketManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        setUpSocket()
        getConversations()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }

//    @IBAction func dismissBt(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//        self.socket!.disconnect()
//    }
//
    @IBAction func dismissBt(_ sender: Any) {
        navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
                self.socket!.disconnect()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell") as! ChatCustomCellController
        cell.userNameLbl.text = "\((self.messages?[indexPath.row].sender_first_name)!) \((self.messages?[indexPath.row].sender_last_name)!)"
        cell.messageLbl.text = self.messages?[indexPath.row].message
       print(self.messages?[indexPath.row].image_path)
        if self.messages?[indexPath.row].image_path != nil {
            var urlString = "https://api.snapgroup.co.il" + (self.messages?[indexPath.row].image_path)!
            if self.messages?[indexPath.row].image_path?.contains("https") == true {
                urlString = (self.messages?[indexPath.row].image_path!)!
            }
            //  print(self.myGrous[indexPath.row].image!)
            cell.userImage.layer.borderWidth = 0
             cell.selectionStyle = .none
            cell.userImage.layer.masksToBounds = false
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
            cell.userImage.clipsToBounds = true
            var url = URL(string: urlString)
            
            cell.userImage.downloadedFrom(url: url!, contentMode: .scaleToFill)

        }
        else {
          print("image not found")
        }
        
        return cell
        
    }
    func getConversations(){
        HTTP.GET("https://dev.snapgroup.co.il/api/getprivatechatlist/74", parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do{
                let  data = try JSONDecoder().decode([Message].self, from: response.data)
            
                 DispatchQueue.main.sync  {
                    self.messages = data
                    self.chatTableView.reloadData()
                }
              //  print(self.messages)
                
            }
            catch {
                
            }
         
        }
           // print("opt finished: \(response.description)")
        
    }
    func setUpSocket(){
        print("----- ABED -----")
       var  manager = SocketManager(socketURL: URL(string: "https://dev.snapgroup.co.il:3030/")!, config: [.log(true),.forcePolling(true)])
        socket = manager.defaultSocket
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "member-74")
            
        }
        socket!.on("member-74:member-channel") {data, ack in
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                    print(messageClass)
                    print(messageClass["id"]!)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ChatUser.currentUser = self.messages?[indexPath.row]
        performSegue(withIdentifier: "privateChatSegue", sender: self)

        print((ChatUser.currentUser?.sender_id!)!)
    }
  
}


public extension UIImageView {
    func downloadedFrom2(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
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
    func downloadedFrom2(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
