//
//  MembersViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/7/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftEventBus
import TTGSnackbar
import ARSLineProgress
struct GroupMember: Codable{
    var id: Int?
    var email: String?
    var first_name: String?
    var last_name: String?
    var profile_image: String?
    var companion_number: Int?
    var status: String?
    var role: String?
}

class MembersViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource , UISearchBarDelegate{
    
    
    @IBOutlet weak var addCompnionBt: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var membersCoView: UICollectionView!
    @IBOutlet weak var membersCountLbl: UILabel!
    
    var isSearching = false
    var singleGroup: TourGroup?
    var members: [GroupMember] = []
    var filterdMembers: [GroupMember] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterdMembers.count
    }
    
  
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text  == "" {
            self.isSearching = false
            dismissKeyboard()
            view.endEditing(true)
            filterdMembers = members
            membersCoView.reloadData()
            
        }
        else{
           self.filterdMembers =  members.filter({ (member) -> Bool in
                let memberFullName: String = member.first_name! + " " + member.last_name!
                if (memberFullName.lowercased().contains(searchBar.text!.lowercased())) {
                    return true
                }
                return false
            })
            self.membersCoView.reloadData()
            
        }
    }
    
    
    @IBAction func addCompanion(_ sender: Any) {
        self.performSegue(withIdentifier: "showAddCompanions", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = membersCoView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! MemberCollectionCell
        
//        cell.memberImage.layer.borderWidth = 0
//        cell.memberImage.layer.masksToBounds = false
//        cell.memberImage.layer.cornerRadius = cell.memberImage.frame.height/2
//        cell.memberImage.clipsToBounds = true
        if self.filterdMembers[indexPath.row].profile_image != nil {
        var urlString = ApiRouts.Media + (self.filterdMembers[indexPath.row].profile_image)!
            print(urlString)
        if self.filterdMembers[indexPath.row].profile_image?.contains("https") == true {
            print("in IF ")
           urlString =  (self.filterdMembers[indexPath.row].profile_image)!
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        var url = URL(string: urlString)

        cell.memberImage.downloadedFrom(url: url!)
        }
        else {
            cell.memberImage.image = UIImage(named: "default member 2")
        }

        if filterdMembers[indexPath.row].first_name != nil && filterdMembers[indexPath.row].last_name != nil {
        cell.memberNameLbl.text = filterdMembers[indexPath.row].first_name! + " " + filterdMembers[indexPath.row].last_name!
        }
        if filterdMembers[indexPath.row].companion_number != nil && filterdMembers[indexPath.row].companion_number! != 0 {
            cell.memberRoleLbl.text =  "(+\(filterdMembers[indexPath.row].companion_number!))"
        }else{
           cell.memberRoleLbl.text = ""
        }
       
        cell.memberImage.contentMode = .scaleAspectFill
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
       // self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "refreshMembers") { result in
            self.getMembers()
        }
        SwiftEventBus.onMainThread(self, name: "GoToPrivateChat") { result in
            self.performSegue(withIdentifier: "privateChatSegue", sender: self)
        }
        if (MyVriables.currentGroup?.role) != nil && (MyVriables.currentGroup?.role)! != "observer"
        {
            addCompnionBt.isHidden = false
        }

        self.singleGroup  = MyVriables.currentGroup!
        self.membersCoView.delegate = self
        self.membersCoView.dataSource = self
        self.searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = .minimal;
        hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        
        getMembers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getMembers(){
        // TODO
        ARSLineProgress.show()
        print("Url get member is " + ApiRouts.Web+"/api/members/\((MyVriables.currentMember?.id)!)/groups/\((MyVriables.currentGroup?.id)!)")
        HTTP.GET(ApiRouts.Api+"/members/\((MyVriables.currentMember?.id)!)/groups/\((MyVriables.currentGroup?.id)!)", parameters: ["hello": "world", "param2": "value2"]) { response in
            ARSLineProgress.hide()

            if let err = response.error {
                print("error: \(err.localizedDescription)")
                DispatchQueue.main.sync {
                    
                    // add to table view
                    self.membersCountLbl.text = "Members (0)"
                    let snackbar = TTGSnackbar(message: "In order to see the members list, please sign in at the top bar", duration: .long)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                return //also notify app of failure as needed
            }
            do{
                self.members  = try JSONDecoder().decode([GroupMember].self, from: response.data)
                self.filterdMembers = self.members
                DispatchQueue.main.sync {
                    // add to table view
                    var totalMembers : Int = 0
                    for member in self.members
                    {
                        if member.companion_number != nil
                        {
                            totalMembers = totalMembers + member.companion_number!
                        }
                    }
                    
                    
                        // add to table view
                        self.membersCountLbl.text = "Members (\(self.members.count + totalMembers))"
                  
                    self.membersCoView.reloadData()
                }
              
            }
            catch let error {
                
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        GroupMembers.currentMemmber = self.filterdMembers[indexPath.row]
        
        performSegue(withIdentifier: "showMemberModal", sender: self)

    }
    @IBAction func onBackPressed(_ sender: Any) {
    navigationController?.popViewController(animated: true)
    }
    
 

}
