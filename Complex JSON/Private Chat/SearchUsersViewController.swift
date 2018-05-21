//
//  SearchUsersViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 30.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
struct ElasticMembers: Codable{
    var data: [ElasticMember]?
}
class SearchUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    @IBOutlet weak var tableview: UITableView!
    var members: [ElasticMember] = []
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

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.searchBar.text != "" && self.searchBar.text != nil
        {
            getGroupMembers(name: self.searchBar.text!)
            view.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        members = []
        tableview.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
        if searchBar.text == nil || searchBar.text  == "" {
            self.isSearching = false
          //  dismissKeyboard()
           // view.endEditing(true)
           
           
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
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serachTableView", for: indexPath) as! SearchTableViewCell
        cell.selectionStyle = .none
        
        cell.personName.text = members[indexPath.row].first_name! + " " + members[indexPath.row].last_name!
        print(members[indexPath.row].images?.count)
        if (members[indexPath.row].images?.count)!  != 0 {
            print("im in \((members[indexPath.row].images?.count)!)")
            var urlString = ApiRouts.Web + (members[indexPath.row].images?[0].path!)!
            if (members[indexPath.row].images?[0].path!)!.contains("http")
            {
                urlString = (members[indexPath.row].images?[0].path!)!
            }
             print("im in \(urlString)")
            var url = URL(string: urlString)
            cell.pesonImage.downloadedFrom(url: url!)
        }
        return cell
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isChatId = false
        /*
         var id: Int?
         var email: String?
         var profile_image: String?
         var first_name: String?
         var last_name: String?
         */
        

        var ProfileImage: String = ""
        if (members[indexPath.row].images?.count)! != 0 {
            ProfileImage = (members[indexPath.row].images?[0].path!)!
        }
        print("profile_image: \(ProfileImage)")

        ChatUser.currentUser = Partner(id: members[indexPath.row].id, email: members[indexPath.row].email, profile_image: ProfileImage , first_name: members[indexPath.row].first_name , last_name: members[indexPath.row].last_name)
        performSegue(withIdentifier: "privateChatSegue", sender: self)

        
    }
    func getGroupMembers(name: String){
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let seachText = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        print(ApiRouts.Web+"/api/members?search=\(name)")
        
        HTTP.GET(ApiRouts.Web + "/api/members?search=\(seachText)" ){response in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
            }else {
                do{
                    let  resp = try JSONDecoder().decode(ElasticMembers.self, from: response.data)
                   self.members = resp.data!
                    self.members = []
                    for mem in resp.data! {
                        if mem.id!  != id {
                            self.members.append(mem)
                        }
                    }
                    print("myMembers: for search -> \(seachText) result is : \(self.members)")
                    DispatchQueue.main.sync {
                        self.tableview.reloadData()
                    }
                }catch {
                    
                }
            }
            
        }
        
        
    }
    
    

}
