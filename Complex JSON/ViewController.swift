//
//  ViewController.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Crashlytics
import SwiftHTTP
import SDWebImage
import MRCountryPicker



/***********************************************      Structrs     *************************************************************/

struct MyVriables {
    static var currentGroup: TourGroup?
    
    
}


struct CurrentMember: Codable{
    //var message: String?
    var member: Member?
    var profile: MemberProfile?
    
}

struct Member: Codable{
    var email: String?
    var phone: String?
    var id: Int?
}
struct MemberProfile: Codable{
    var member_id: Int?
    var first_name: String?
    var last_name: String?
    var email: String?
    var gender: String?
    var birth_date: String?
    var profile_image: String?
   
    
}

struct Toy: Codable {
    var name: String?
    var last: String?
}
/***********************************************      VIEW CONTROLLER     *************************************************************/


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,  MRCountryPickerDelegate{
    
    // header views
    
   
    var PINCODE: String?
    var phoneNumber: String?
    
    /********  VIEWS ***********/
    @IBOutlet weak var countryPicker: MRCountryPicker!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var countryPrefLable: UILabel!
    @IBOutlet weak var chatHeaderStackView: UIStackView!
    @IBOutlet weak var phoneNumberStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneNumberFeild: UITextField!

    @IBOutlet weak var filterView: UIView!
    /********* CONSTRAINTS **********/
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    /******* VARIABLES *********/
    
    var myGrous: [TourGroup] = []
    var currentGroup: TourGroup?
    var currentMember: CurrentMember?
    let cellSpacingHeight: CGFloat = 5
    var whatIsCurrent: Int  = 0
    var hasLoadMore: Bool = true
    var refresher: UIRefreshControl!
    var dbRererence: DatabaseReference?
    var page: Int = 1
    var groupImages: [GroupImage] = []
    var flagImage: UIImage?
    var currentProfile: MemberProfile?
    var isFilterShowing: Bool = false
    @IBAction func onFilterTapped(_ sender: Any) {
        if isFilterShowing {
            leadingConstraint.constant = -199
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})

        }
        else{
            
            leadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})

        }
        
        isFilterShowing = !isFilterShowing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        phoneNumberFeild.keyboardType = .numberPad
        setCountryPicker()
        setChatTap()
        setRefresher()
        self.checkCurrentUser()
        DispatchQueue.main.async {
            self.getSwiftGroups(){ (output) in
                
            }
        }
        setFilterView()
    }
    func setFilterView(){
        filterView.layer.shadowColor = UIColor.black.cgColor
        filterView.layer.shadowOpacity = 0.5
        filterView.layer.shadowOffset = CGSize.zero
        filterView.layer.shadowRadius = 4
    }
    func setRefresher(){
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    
    
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.flagImageView.image = flag
        self.countryPrefLable.text = phoneCode
        self.countryPicker.isHidden = true
        
    }
    
    
    
    func checkCurrentUser(){
        print("hihihi")
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let first = defaults.string(forKey: "first_name")
        let last = defaults.string(forKey: "last_name")
        let email = defaults.string(forKey: "email")
        let phone = defaults.string(forKey: "phone")
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == true{
                   self.phoneNumberStackView.isHidden = true
                   self.chatHeaderStackView.isHidden = false
        }
       

    //    let prfoile = MemberProfile(member_id: id)
        
        
    }
    
    
    func setChatTap(){
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("chatTapped"))
        chatImageView.isUserInteractionEnabled = true
        chatImageView.addGestureRecognizer(singleTap)
    }
    
  @objc  func chatTapped(){
    print("chat tapped")
    
    performSegue(withIdentifier: "showChat", sender: self)

    }
    
    
   
    
    @objc func refreshData(){
        print("refresh is loading")
        self.page = 1
        self.myGrous = []
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.getSwiftGroups(){ (output) in
            }
        }
        
    }
    
    @IBAction func onPickerTapped(_ sender: Any) {
        self.countryPicker.isHidden = false

    }
    
    
   
    
    
    func setCountryPicker(){
        countryPicker.isHidden = true
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            countryPicker.setLocale(countryCode)
        }
          countryPicker.setCountry(Locale.current.regionCode!)
    }
    
    
    
    @IBAction func sendClick(_ sender: Any) {
        
        print("\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)")
        self.phoneNumber = "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"
        
        let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)", preferredStyle: .alert)
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            let params = ["phone": self.phoneNumber]
            
            HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
                
                if response.statusCode == 201 {
                    print ("successed")
                    
                    let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
                    
                    PinAlert.addTextField { (textField) in
                        textField.placeholder = "1234"
                        
                    }
                    PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
                        let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
                        self.PINCODE = textField?.text
                        print("PIN CODE : \((textField?.text)!)")
                        
                        let params = ["code": (textField?.text)!, "phone": "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"]
                        HTTP.POST(ApiRouts.Register, parameters: params) { response in
                            //do things...
                           
                            print(response.description)
                            do{
                             let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                                print(member)
                                
                                self.currentMember = member
                                self.setToUserDefaults(value: true, key: "isLogged")
                                print(self.currentMember?.profile!)
                                self.setToUserDefaults(value: self.currentMember?.profile?.member_id!, key: "member_id")
                                self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                                self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                                self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                                self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                                self.currentProfile = self.currentMember?.profile!
                                DispatchQueue.main.sync {
                                    self.phoneNumberStackView.isHidden = true
                                    self.chatHeaderStackView.isHidden = false
                                }
                              
                                
                          
                            }
                            catch {
                                print("catch error")
                                self.phoneNumberStackView.isHidden = false
                                self.chatHeaderStackView.isHidden = true
                                self.setToUserDefaults(value: false, key: "isLogged")

                            }

                        }
                        
                        
                        
                        
                    }))
                    PinAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCLE", comment: "Default action"), style: .`default`, handler: { _ in
                        print("no")
                        
                    }))
                    self.present(PinAlert, animated: true, completion: nil)
                    

                }
                
                //do things...
            }
            
          
            
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")

            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    
    
    
    
    // get groups reqeust: by page
    
    func getSwiftGroups(completionBlock: @escaping ([TourGroup]?) -> Void) -> Void {
        print("request PAGE = \(self.page)")
        let params = ["page": self.page]
        var groups: [TourGroup]?
        HTTP.POST(ApiRouts.AllGroupsRequest, parameters: params) { response in
            print(ApiRouts.AllGroupsRequest)
            //do things...
          //  print(response.description)
            let data = response.data
            do {
                let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                
                groups = groups2.data!
                if groups?.count == 0 {
                    self.hasLoadMore = false
                    return
                }

                DispatchQueue.main.sync {
                    for group in groups! {
                        self.myGrous.append(group)
                    }
                 //   self.myGrous = groups!
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    completionBlock(groups)
                }
              //  print(self.myGrous.count)
            }
            catch {
                
            }
            
        }
    }
    
    // not needed
    @objc func onClick(sender: UIButton!){
        print("clicked")
        performSegue(withIdentifier: "showModal", sender: self)

        
        
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? GroupViewController {
            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
        }
        
        if let destination = segue.destination as? HomeViewController {
            print("home destination")
            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
        }
    }


    
    /////////////////////////////// Tableview initialize ///////////////////////////
    
    
    // pagination loadmore : check last item
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastitem =  self.myGrous.count - 1
        if indexPath.row == lastitem && hasLoadMore == true{
            
            DispatchQueue.main.async {
                self.getSwiftGroups(){ (output) in
                    
                }
            }
        }
    }
    
    // tableview: tableview count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("hi \(myGrous.count)")
        return self.myGrous.count
    }
    
    
    // tableview: return the cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        if self.myGrous[indexPath.row].image != nil{
        
            do{
                let urlString = try ApiRouts.Web + (self.myGrous[indexPath.row].image)!
                var url = URL(string: urlString)
                if url == nil {
                }
                else
                {
                    cell.imageosh.downloadedFrom(url: url! , contentMode: .scaleToFill)
                }
            }
            catch{
      
            }
        }

        cell.selectionStyle = .none
       
        
        cell.groupLabel.text = self.myGrous[indexPath.row].title
        
        
        
        return cell
        
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
    
    
    // tableview: selected row
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if !self.isFilterShowing {
                self.leadingConstraint.constant = -199
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                self.isFilterShowing = !self.isFilterShowing
            }
        
        MyVriables.currentGroup = self.myGrous[indexPath.row]
        self.performSegue(withIdentifier: "groupDetailsBar", sender: self)
        
        
       
        
    }
    
    // height for each section
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.cellSpacingHeight
    }
    


}

public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

