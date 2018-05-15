//
//  RecentGroupViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class RecentGroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell") as! RecentTableViewCell
        
        if indexPath.row == 0 {
            cell.titleLbl.text = "הפקות ירושלים בע״ם"
            cell.actionLbl.text = "you've created a new group"
            cell.timeLbl.text = "14:22"
        }
        if indexPath.row == 1 {
            cell.titleLbl.text = "Yoga times"
            cell.actionLbl.text = "you've sent a new message"
            cell.timeLbl.text = "13:12"
        }
        if indexPath.row == 2 {
            cell.titleLbl.text = "שקט מרפא הכל"
            cell.actionLbl.text = "you've visited the group"
            cell.timeLbl.text = "20:22"
        }
        if indexPath.row == 3 {
            cell.titleLbl.text = "קרנות שוטרים באילת"
            cell.actionLbl.text = "you've created a new group"
            cell.timeLbl.text = "14:22"
        }
        if indexPath.row == 4 {
            cell.titleLbl.text = "הפקות ירושלים בע״ם"
            cell.actionLbl.text = "you've created a new group"
            cell.timeLbl.text = "14:22"
        }
        if indexPath.row == 5 {
            cell.titleLbl.text = "Yoga times"
            cell.actionLbl.text = "you've sent a new message"
            cell.timeLbl.text = "13:12"
        }
        if indexPath.row == 6{
            cell.titleLbl.text = "שקט מרפא הכל"
            cell.actionLbl.text = "you've visited the group"
            cell.timeLbl.text = "20:22"
        }
        return cell
    }
    

    @IBOutlet weak var recentGroupsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentGroupsTable.delegate = self
        recentGroupsTable.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
