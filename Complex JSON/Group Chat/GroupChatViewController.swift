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

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
 
     var chatMessages: [ChatListGroupItem]?
    var messages: ChatGroup?
    var chatsMessages: ChatGroup?
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.tableFooterView = UIView()
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.allowsSelection = false
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
    
        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowOffset = CGSize.zero
        headerView.layer.shadowRadius = 1
       
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
           print(self.messages?.messages?.count)
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
        if self.messages?.messages![indexPath.row].member_id! == MyVriables.currentMember?.id!
        {
            if (self.messages?.messages![indexPath.row].type)! == "text"
            {
                if self.messages?.messages![indexPath.row].message != nil {
                    cell2.textLbl.text = (self.messages?.messages?[indexPath.row].message!)!
                }
                
            }
            return cell2
        }
        else {
           
            if self.messages?.messages![indexPath.row].type! == "text"
            {
                if (self.messages?.messages?[indexPath.row].message) != nil {

                    //print(" MESSAGE IS : \((self.messages?.messages?[indexPath.row].message!)!)")
                    cell.textLbl.text = "\((self.messages?.messages?[indexPath.row].message!)!)"
                   
                }
            }
            
            return cell
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
                        
                    for message in (self.messages?.messages)!
                    {
                        self.chatMessages?.append(message)
                        //print(message)
                    }
    
                   // print("chat messsages is :::: \((self.chatMessages?.count)!)")
                    self.chatTableView.reloadData()
                }
            }
            catch {
                
            }
    
            
        }
        
        
    }

}
