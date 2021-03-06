//
//  CheckListViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//



import UIKit
import SwiftHTTP




class CheckListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
     var check_list: [GroupCheckList]?
    typealias sectionType = [(HeaderVew: UIView, height: CGFloat)]
    let sectionTitleArray = ["Required","Recomnded"]
    // Data Array
    var exam: [GroupCheckList] = []
    var examp: [GroupCheckList] = []
    var dataArray1 : [GroupCheckList] = []
    var dataArray2 : [GroupCheckList] = []
    var dataArrayGroup: [[GroupCheckList]] = []
    var globalSection: Int = -1
    
    var globalRow: Int = -1
    var sectionItemArray: [(HeaderVew: UIView, height: CGFloat)] = Array()
    
    @IBAction func onBack(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableViewCheckList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
  
        
        // Create Section Header Data
        sectionItemArray = self.generateSectionHeader(titleArray: sectionTitleArray, parentView: self.view)
        
        tableViewCheckList.tableFooterView = UIView()
        tableViewCheckList.estimatedRowHeight = 20
        tableViewCheckList.rowHeight = UITableViewAutomaticDimension
        tableViewCheckList.allowsSelection = false
        tableViewCheckList.delegate = self
        tableViewCheckList.dataSource = self
        tableViewCheckList.separatorStyle = .none
         getGroupChecklist()
       // self.tableViewCheckList
        // Do any additional setup after loading the view.
    }
    // Generate Section Header Data
    func generateSectionHeader(titleArray: [String], parentView: UIView) -> sectionType {
        var sectionHeaderArray = sectionType()
        for sectionTitle in titleArray {
            if sectionTitle.isEmpty {
                
                // No Section Header
                sectionHeaderArray.append((HeaderVew: UIView(),height: 0))
            } else {
                
                // Make Section Header
                let sectionBaseView = UIView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 25))
                sectionBaseView.backgroundColor = UIColor(red: 0.8514, green: 0.8514, blue: 0.8514, alpha: 1.0)
                let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: parentView.frame.size.width - 20, height: 25))
                headerLabel.text = sectionTitle
                headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
                sectionBaseView.addSubview(headerLabel)
                sectionHeaderArray.append((HeaderVew: sectionBaseView,height: 25))
            }
        }
        return sectionHeaderArray
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArrayGroup[section].count
    
    }
    // Section Header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionItemArray[section].HeaderVew
    }
    
    // Section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print(sectionItemArray[section].height)
        return sectionItemArray[section].height
    }
    
    // Section Count
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArrayGroup.count
    }
    
    
    // Row Count
    func tableView(_tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArrayGroup[section].count
    }
    
    // Generate Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCheckListItem", for: indexPath) as! CheckListItemCell
       // print(dataArrayGroup[indexPath.section][indexPath.row])

            cell.itemLbl.text = dataArrayGroup[indexPath.section][indexPath.row].item
        
            if dataArrayGroup[indexPath.section][indexPath.row].checked != nil {
                if dataArrayGroup[indexPath.section][indexPath.row].checked! == true {
                    cell.itemSwitch.setOn(true, animated: true)
                }
                else{
                    cell.itemSwitch.setOn(false, animated: true)
                }
            }
        cell.itemSwitch.tag = dataArrayGroup[indexPath.section][indexPath.row].id! // for detect which row switch Changed

        cell.itemSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        
            cell.itemSwitch.addTarget(self, action:#selector(switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = cell.itemSwitch
        
       
        return cell
    }
   @objc func switchChanged(_ sender : UISwitch!)
    {
        if sender.isOn {
            setCheckedTrue(id: sender.tag,checked: "true")
        }
        else
        {
            setCheckedTrue(id: sender.tag,checked: "false")

        }
        
        
        print("table row switch Changed \(sender.tag))")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
    }
    
    // Select Cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getGroupChecklist(){
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        print(ApiRouts.Web+"/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\(id)/checklist")
        
        HTTP.GET(ApiRouts.Web+"/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\(id)/checklist", parameters: ["hello": "world", "param2": "value2"])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
           
            
            do{
            self.check_list  = try JSONDecoder().decode([GroupCheckList].self, from: response.data)
                //print(self.check_list)
                
                print(self.dataArray1)
                DispatchQueue.main.sync {
                    // add to table view
                    // add to table view
                    
                    for checklist in self.check_list! {
                        print("im here in checlist loop ")
                        if checklist.required == false {
                            self.dataArray1.append(checklist)
                        }
                        else
                        {
                            self.dataArray2.append(checklist)
                        }
                        
                        print(checklist.checked)
                    }
                    
                    if self.dataArray1.count == 0 && self.dataArray2.count == 0 {
                        
                    }
                    else
                    {
                        self.dataArrayGroup = [self.dataArray1, self.dataArray2]
                         self.tableViewCheckList.reloadData()
                    }
                   
                }
            }
            catch let error {
            }
            
        }
            
        
    }
    
    func setCheckedTrue(id : Int,checked : String)
    {
        let myId =  (MyVriables.currentMember?.id!)!
        print("5555"+ApiRouts.Web+"/api/checklist/\(id)?member_id=\(myId)&group_id=70&checked=\(checked)")
        HTTP.PUT(ApiRouts.Web+"/api/checklist/\(id)?member_id=\(myId)&group_id=\((MyVriables.currentGroup?.id!)!)&checked=\(checked)", parameters: ["hello": "world", "param2": "value2"])
        {
            response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print(response.description)
            
         
            
        }
    }

    
    

}
