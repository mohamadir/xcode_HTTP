//
//  PrivateChatViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/2/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit



class PrivateChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
  
    
    @IBOutlet weak var usernamelb: UILabel!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextFeild: UITextField!
    var messageUser: Message?
    
    @IBAction func onClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageUser = ChatUser.currentUser!
        self.usernamelb.text = "\((self.messageUser?.sender_first_name)!) \((self.messageUser?.sender_last_name)!)"

    }


    @IBAction func sendTapped(_ sender: Any) {
    }
    
    // chat table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}
