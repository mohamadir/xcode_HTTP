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
import AlamofireImage

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}


struct ChatList: Codable {
    var chats: [ChatListItem]
}

class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTableView: UITableView!
    var messages: [ChatListItem]? = []
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        setUpSocket()

        self.reloadView()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

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
    func setToUserDefaults(value: Any?, key: String){
        if value != nil {
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
        }
        else{
            let defaults = UserDefaults.standard
            defaults.set("no value", forKey: key)
        }
        
        
    }
    @IBAction func dismissBt(_ sender: Any) {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
        }
        if  navigationController?.viewControllers.count != 0 {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "showMainSegue", sender: self)
          
        }
        setToUserDefaults(value: 0, key: "chat_counter")
        
        self.socket!.disconnect()

        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    @objc func reloadView(){
        print("VIEW APPEARED !!! ")
        self.getConversations()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        DispatchQueue.main.async {
            self.setUpSocket()
            self.messages = []
            self.chatTableView.reloadData()
            self.getConversations()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell") as! ChatCustomCellController
        if self.messages?[indexPath.row].partner != nil {
        cell.userNameLbl.text = "\((self.messages?[indexPath.row].partner?.first_name)!) \((self.messages?[indexPath.row].partner?.last_name)!)"
        }
        cell.messageLbl.text = self.messages?[indexPath.row].last_message?.message!
        if self.messages?[indexPath.row].total_unread! != 0 {
            
            cell.budgesView.isHidden = false
            cell.budgesCountLbl.text = "\((self.messages?[indexPath.row].total_unread)!)"
            
        }else {
            cell.budgesView.isHidden = true

        }
        if self.messages?[indexPath.row].partner?.profile_image != nil {
            var urlString = ApiRouts.Web + (self.messages?[indexPath.row].partner?.profile_image)!
            if self.messages?[indexPath.row].partner?.profile_image?.contains("https") == true {
                urlString = (self.messages?[indexPath.row].partner?.profile_image!)!
            }
            //  print(self.myGrous[indexPath.row].image!)
            cell.userImage.layer.borderWidth = 0
             cell.selectionStyle = .none
            cell.userImage.layer.masksToBounds = false
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
            cell.userImage.clipsToBounds = true

            var url = URL(string: urlString)
//            DispatchQueue.main.async {
//                cell.userImage.downloadedFrom(url: url!, contentMode: .scaleToFill)
//
//            }
            print(url!)
            if self.messages?[indexPath.row].partner?.profile_image?.contains("https") == true {
                cell.userImage.downloadedFrom(url: url!)
            }
            else{

                cell.userImage.sd_setImage(with: url!, placeholderImage: UIImage(named: "default user"))
                cell.userImage.contentMode = .scaleAspectFill
                
            
            }

        }
        else {
        }
        
        return cell
        
    }
    func getConversations(){
        HTTP.GET("\(ApiRouts.Web)/api/chats?member_id=\((MyVriables.currentMember?.id!)!)", parameters: []) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do{
                let  data = try JSONDecoder().decode(ChatList.self, from: response.data)
                DispatchQueue.main.sync {
                    self.messages = data.chats
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
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        print("chat api: "+ApiRouts.ChatServer)
        socket = manager.defaultSocket
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "member-ֿ\((MyVriables.currentMember?.id!)!)")
            
        }
        socket!.on("member-\((MyVriables.currentMember?.id!)!):member-channel") {data, ack in
            self.getConversations()
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
    @IBAction func searchPersons(_ sender: Any) {
        performSegue(withIdentifier: "showSearchViewControler", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ChatUser.currentUser = self.messages?[indexPath.row].partner!
        ChatUser.ChatId = self.messages?[indexPath.row].last_message?.chat_id!
        performSegue(withIdentifier: "privateChatSegue", sender: self)
        self.socket?.disconnect()
        print((ChatUser.currentUser)!)
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
