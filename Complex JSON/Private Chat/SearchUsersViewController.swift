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
    var members: [ElasticMember]?
}
class SearchUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    @IBOutlet weak var tableview: UITableView!
    var members: [ElasticMember] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.addTapGestureRecognizer {
        self.navigationController?.popViewController(animated: true)
          
        }
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
     
        print("Search is \(searchBar.text!)")
        if searchBar.text == nil || searchBar.text  == "" {
             print("Search is Empity")
            
             self.members = []
               self.tableview.reloadData()
                view.endEditing(true)
           
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.getGroupMembers(name: self.searchBar.text!)
                
            })
            
            
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
        cell.personName.text = (members[indexPath.row].first_name != nil ?  members[indexPath.row].first_name! : "Guset" ) + " " + (members[indexPath.row].last_name != nil ? members[indexPath.row].last_name! : "\((members[indexPath.row].member_id)!)")
        if members[indexPath.row].profile_image != nil {
            var urlString = ApiRouts.Media + (members[indexPath.row].profile_image)!
            if (members[indexPath.row].profile_image)!.contains("http")
            {
                urlString = (members[indexPath.row].profile_image!)
            }
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
             print("im in \(urlString)")
            var url = URL(string: urlString)
            cell.pesonImage.downloadedFrom(url: url!)
         cell.pesonImage.contentMode = .scaleAspectFill
        
        }
        else
        {
            cell.pesonImage.image = UIImage(named: "default member 2")
        }
        return cell
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isChatId = false
        var ProfileImage: String = ""
        if (members[indexPath.row].profile_image) != nil {
            ProfileImage = (members[indexPath.row].profile_image)!
        print("profile_image: \(ProfileImage)")
        }
        print("member id is = \(members[indexPath.row].member_id!)")
        ChatUser.currentUser = Partner(id: members[indexPath.row].member_id, email: members[indexPath.row].email != nil ? (members[indexPath.row].email)! : "", profile_image: ProfileImage , first_name: members[indexPath.row].first_name != nil ? (members[indexPath.row].first_name)! : "", last_name: (members[indexPath.row].last_name) != nil ? (members[indexPath.row].last_name)! : "")
        performSegue(withIdentifier: "privateChatSegue", sender: self)

        
    }
    func getGroupMembers(name: String){
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let seachText = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        print(ApiRouts.Api+"/members?search=\(name)")
        
        HTTP.GET(ApiRouts.Api + "/members?search=\(seachText)" ){response in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
            }else {
                do{
                    let  resp = try JSONDecoder().decode(ElasticMembers.self, from: response.data)
                    DispatchQueue.main.sync {
                        self.members = []
                        for mem in resp.members! {
                        if mem.member_id!  != id {
                            self.members.append(mem)
                        }
                    }
                    print("myMembers: for search -> \(seachText) result is : \(self.members)")
                    
                        self.tableview.reloadData()
                    }
                }catch {
                    
                }
            }
            
        }
        
        
    }
    
    

}
