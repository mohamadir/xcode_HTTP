//
//  MemberInboxViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/6/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class MemberInboxViewController: UIViewController , UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var inboxTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("notification cell print")
         let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationCell
        return cell
    }
    
    @IBOutlet weak var inboxTabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inboxTabelView.separatorStyle = .none
        inboxTabelView.delegate = self
        inboxTabelView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backPressed(_ sender: Any) {
    }
    
}
