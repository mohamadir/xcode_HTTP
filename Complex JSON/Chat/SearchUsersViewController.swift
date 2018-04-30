//
//  SearchUsersViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 30.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
class SearchUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableFooterView = UIView()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        self.searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = .minimal;
        //UISearchBarDelegate
        hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
        if searchBar.text == nil || searchBar.text  == "" {
            self.isSearching = false
            dismissKeyboard()
            view.endEditing(true)
           
          //  membersCoView.reloadData()
            
        }
        else{
//           // self.filterdMembers =  members.filter({ (member) -> Bool in
//                let memberFullName: String = member.first_name! + " " + member.last_name!
//                if (memberFullName.lowercased().contains(searchBar.text!.lowercased())) {
//                    return true
//                }
//                return false
//            })
          //  self.membersCoView.reloadData()
            
        }
    }
    @IBAction func searchClick(_ sender: Any) {
        if self.searchBar.text != "" && self.searchBar.text != nil
        {
            getGroupMembers(name: self.searchBar.text!)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
             self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serachTableView", for: indexPath) as! SearchTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func getGroupMembers(name: String){
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        print(ApiRouts.Web+"/api/members?search=\(name)")
        
        HTTP.GET(ApiRouts.Web+"/api/members?search=\(name)", parameters: [])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            print(response.data)
//            do{
//               // self.check_list  = try JSONDecoder().decode([GroupCheckList].self, from: response.data)
//                //print(self.check_list)
//
//                print(self.dataArray1)
//                DispatchQueue.main.sync {
//                    // add to table view
//                    // add to table view
//
//                    for checklist in self.check_list! {
//                        print("im here in checlist loop ")
//                        if checklist.required == false {
//                            self.dataArray1.append(checklist)
//                        }
//                        else
//                        {
//                            self.dataArray2.append(checklist)
//                        }
//
//                        print(checklist.checked)
//                    }
//
//                    if self.dataArray1.count == 0 && self.dataArray2.count == 0 {
//
//                    }
//                    else
//                    {
//                        self.dataArrayGroup = [self.dataArray1, self.dataArray2]
//                        self.tableViewCheckList.reloadData()
//                    }
//
//                }
//            }
//            catch let error {
//            }
            
        }
        
        
    }
    

}
