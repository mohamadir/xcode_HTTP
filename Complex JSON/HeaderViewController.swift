//
//  HeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus
class HeaderViewController: UIViewController {


    @IBOutlet weak var inboxCounterLbl: UILabel!
    @IBOutlet weak var InboxCounterView: DesignableView!
    @IBOutlet weak var chatCounterLbl: UILabel!
    @IBOutlet weak var ChatCounterView: DesignableView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var inboxView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "counters") { (result) in
            self.setBadges()
        }
        
        inboxView.addTapGestureRecognizer {
            print("INBOX PRESSE")
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Notifications") as? MemberInboxViewController {

                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        chatView.addTapGestureRecognizer {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as? ChatViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
      print("IM HERE FROM NOTF AND CHAT")
    }
    override func viewWillAppear(_ animated: Bool) {
        setBadges()
    }
    
    func setBadges(){
        let defaults = UserDefaults.standard
        let chat_counter = defaults.integer(forKey: "chat_counter")
        let inbox_counter = defaults.integer(forKey: "inbox_counter")
        print("ICOUNTER- notifications counters: \(inbox_counter)")
        print("ICOUNTER- messages counters: \(chat_counter)")
        
        if chat_counter
            != 0 {
            ChatCounterView.isHidden = false
            chatCounterLbl.text = "\(chat_counter)"
        }else {
            ChatCounterView.isHidden = true
        }
        
        if inbox_counter != 0 {
            InboxCounterView.isHidden = false
            inboxCounterLbl.text = "\(inbox_counter)"
        }else {
            InboxCounterView.isHidden = true
        }
        
    }

    @IBAction func backPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
