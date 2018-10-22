//
//  MemberInboxViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/6/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP

class MemberInboxViewController: UIViewController , UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var inboxTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    var refresher: UIRefreshControl!
    var messageArray: [InboxMessage] = []
    var page: Int = 1
    var hasLoadMore: Bool = true

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
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
    override func viewWillAppear(_ animated: Bool) {
        setToUserDefaults(value: 0, key: "inbox_counter")
        if MyVriables.MemberInboxShouldRefresh {
            MyVriables.MemberInboxShouldRefresh = false
            refreshData()
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationCell
        cell.selectionStyle = .none
        if self.messageArray[indexPath.row].read == 0  {
            cell.ItemView.backgroundColor = Colors.InboxItemBg
             cell.backgroundColor = UIColor.white
        }
        else {
            cell.backgroundColor = Colors.InboxItemBg
            cell.ItemView.backgroundColor = UIColor.white
        }
        if self.messageArray[indexPath.row].type == "notification" {
            cell.messageIconImageview.image = UIImage(named: "group Leader icon")
            cell.groupTitleLbl.text = (self.messageArray[indexPath.row].first_name != nil ? self.messageArray[indexPath.row].first_name! : "") + " " + (self.messageArray[indexPath.row].last_name != nil ? self.messageArray[indexPath.row].last_name! : "")
            cell.titlelbl.text = "From: " + (self.messageArray[indexPath.row].title != nil ? self.messageArray[indexPath.row].title! : "")
             cell.bodyLbl.text = self.messageArray[indexPath.row].body!
            
            
        }
        else if self.messageArray[indexPath.row].type == "invite_group" {
            cell.groupTitleLbl.text = "Snapgroup"
            cell.titlelbl.text = self.messageArray[indexPath.row].subject!
            cell.bodyLbl.text = self.messageArray[indexPath.row].body!
            cell.dateLbl.text = self.messageArray[indexPath.row].created_at!
            cell.messageIconImageview.image = UIImage(named: "group invitation")
        }
      else  if self.messageArray[indexPath.row].type == "invite" {
            cell.messageIconImageview.image = UIImage(named: "Pair")
            cell.groupTitleLbl.text = self.messageArray[indexPath.row].first_name! + " " + self.messageArray[indexPath.row].last_name!
            cell.titlelbl.text = self.messageArray[indexPath.row].first_name! + " " + self.messageArray[indexPath.row].last_name! + " want to pair with you in this group."
            cell.bodyLbl.text = "Do you want to pair with " + self.messageArray[indexPath.row].first_name! + " " + self.messageArray[indexPath.row].last_name! + "in " + self.messageArray[indexPath.row].title! + " group ?"
            cell.dateLbl.text = self.messageArray[indexPath.row].created_at!
        }
        return cell

        
    }
    
    @IBOutlet weak var inboxTabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.addTapGestureRecognizer {
            self.navigationController?.popViewController(animated: true)
        }
        inboxTabelView.separatorStyle = .none
        inboxTabelView.delegate = self
        inboxTabelView.dataSource = self
        setRefresher()
        self.getMessages()
    }
    func setRefresher(){
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.inboxTabelView.addSubview(refresher)
        
    }
    @objc func refreshData(){
        print("refresh is loading")
        self.page = 1
        self.messageArray = []
        self.hasLoadMore = true
        self.inboxTabelView.reloadData()
        self.getMessages()
        
        
    }
    func getMessages(){
        print(ApiRouts.ApiV3+"/notifications/members/\((MyVriables.currentMember?.id!)!)?page=\(page)")
        HTTP.GET(ApiRouts.ApiV3+"/notifications/members/\((MyVriables.currentMember?.id!)!)?page=\(page)", parameters: []) { response in
            if response.error != nil{
              
            }
            else{
                do{
                 let tempMessageArray = try JSONDecoder().decode(InboxMessageObj.self, from: response.data)
                    
                    if (tempMessageArray.last_page)! < self.page {
                        self.hasLoadMore = false
                        return
                    }
                    
                    DispatchQueue.main.sync {
                        
                        for message in tempMessageArray.data {
                            if !self.messageArray.contains(where: { (mMessage) -> Bool in
                                return mMessage.id == message.id
                            }) {
                                self.messageArray.append(message)
                            }
                        }
                        self.inboxTabelView.reloadData()
                        if self.refresher.isRefreshing{
                            self.refresher.endRefreshing()
                        }
                        self.page += 1

                    }
                    
                }catch let error{
                    print(error)
                }
            }
            
            //do things...
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastitem =  self.messageArray.count - 1
        if indexPath.row == lastitem && hasLoadMore == true{
                self.getMessages()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MyVriables.currentInboxMessage = messageArray[indexPath.row]
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath)! as! NotificationCell
            cell.backgroundColor = Colors.InboxItemBg
            cell.ItemView.backgroundColor = UIColor.white
        }
        markRead(id: messageArray[indexPath.row].id!)
        performSegue(withIdentifier: "showMessageItem", sender: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
    
    
    func markRead(id: Int){
        print(ApiRouts.Web + "/api/notifications/\(id)/\((MyVriables.currentMember?.id!)!)")
        HTTP.PUT(ApiRouts.Api + "/notifications/\(id)/members/\((MyVriables.currentMember?.id!)!)") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription) not mark read")
                
                return //also notify app of failure as needed
            }
            print(response.description)
          
           
            //print("data is: \(response.data)") access the response of the data with response.data
        }
        
        
    }
    
    
}
