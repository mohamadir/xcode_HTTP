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
import UserNotifications
import ARSLineProgress
import Toast_Swift
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
/***********************************************      VIEW CONTROLLER     *************************************************************/


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,  MRCountryPickerDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    // header views
    

    var PINCODE: String?
    var phoneNumber: String?
    ///////// GROUP SETTINGS

    
    /********  VIEWS ***********/
    @IBOutlet weak var countryPicker: MRCountryPicker!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var countryPrefLable: UILabel!
    @IBOutlet weak var chatHeaderStackView: UIView!
    @IBOutlet weak var phoneNumberStackView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneNumberFeild: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var memberMenuView: UIView!
    @IBOutlet weak var memberNameLbl: UILabel!
    @IBOutlet weak var memberPhoneLbl: UILabel!
    @IBOutlet weak var memberGenderLbl: UILabel!
    @IBOutlet weak var notificationsImageView: UIImageView!
    /********* Filter Buttons **********/
    @IBOutlet weak var myGroupsBt: UIButton!
    @IBOutlet weak var managamentBt: UIButton!
    @IBOutlet weak var publicGroupsbt: UIButton!
    @IBOutlet weak var oneDayBt: UIButton!
    @IBOutlet weak var multiDaysBt: UIButton!
    @IBOutlet weak var createdSortBt: UIButton!
    @IBOutlet weak var allGroupsBt: UIButton!
    
    /****** Sort Buttons ************/
    
    @IBOutlet weak var DepratureSortBt: UIButton!
    @IBOutlet weak var totalDaysBt: UIButton!
    
    
   
    
    /********* CONSTRAINTS **********/
  
    @IBOutlet weak var memberLeadingConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    /******* VARIABLES *********/
    var menuIcon: String = "iMenuIcon"
    var myGrous: [TourGroup] = []
    var currentGroup: TourGroup?
    var currentMember: CurrentMember?
    let cellSpacingHeight: CGFloat = 5
    var whatIsCurrent: Int  = 0
    var hasLoadMore: Bool = true
    var refresher: UIRefreshControl!
    var dbRererence: DatabaseReference?
    var search  = ""
    var page: Int = 1
    var standart_sort: String = "created_at&order=desc"
    var groupImages: [GroupImage] = []
    var flagImage: UIImage?
    var currentProfile: MemberProfile?
    var isFilterShowing: Bool = false
    
    // sort & filter variables
    var filter: String = "no-filter"
    var sort: String = ""
    var isLogged: Bool = false
    var id: Int = -1
    var isMemberMenuShowing: Bool = false
    @IBAction func onFilterTapped(_ sender: Any) {
        if isFilterShowing {
            leadingConstraint.constant = -199
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})

        }
        else{
            if isMemberMenuShowing {
                menuButton.setImage(UIImage(named: menuIcon), for: .normal)
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                memberLeadingConstraints.constant = 190
                isMemberMenuShowing = !isMemberMenuShowing
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            }
            leadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})

        }
        
        isFilterShowing = !isFilterShowing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if MyVriables.shouldRefresh {
            refreshList()
            MyVriables.shouldRefresh = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
   
    
    func subScribe(){
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().subscribe(toTopic: "/topics/a123458")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("roleStatus",  "hihihi")
     //   UIApplication.shared.registerForRemoteNotifications()
        if Messaging.messaging().fcmToken != nil {
        print("subscribedddd")
            UIApplication.shared.registerForRemoteNotifications()
            MyVriables.CurrentTopic = "abd123"
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        phoneNumberFeild.keyboardType = .numberPad
        setCountryPicker()
        setChatTap()
        setNotificationTap()
        setRefresher()
       
        self.checkCurrentUser()
       
        setFilterView()
        setMemberMenuView()
    }
    
    func setFilterView(){
        filterView.layer.shadowColor = UIColor.black.cgColor
        filterView.layer.shadowOpacity = 0.5
        filterView.layer.shadowOffset = CGSize.zero
        filterView.layer.shadowRadius = 4
    }
    
    func setMemberMenuView(){
        memberMenuView.layer.shadowColor = UIColor.black.cgColor
        memberMenuView.layer.shadowOpacity = 0.5
        memberMenuView.layer.shadowOffset = CGSize.zero
        memberMenuView.layer.shadowRadius = 4
    }
    func setRefresher(){
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "") // PULL TO REFRESH
        refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    @IBAction func changePhotoTapped(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: URL
        if #available(iOS 11.0, *) {
             image = info[UIImagePickerControllerImageURL] as! URL
        } else {
            // Fallback on earlier versions
            image = info[UIImagePickerControllerReferenceURL] as! URL
            
        }
        ARSLineProgress.show()
        print("image ref: \(image)" )
        
        dismiss(animated: true, completion: nil)
        print("UPLOADIMAGE- url - "+"https://api.snapgroup.co.il/api/upload_single_image/Member/\(MyVriables.currentMember?.id!)/profile")
        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/profile", parameters: ["single_image": Upload(fileUrl: image.absoluteURL)]) { response in
            print("response is : \(response.data)")
            ARSLineProgress.hide()
            let data = response.data
            do {
                if response.error != nil {
                    print("response is : ERROR \(response.error)")
                    
                    return
                }
                let  image2 = try JSONDecoder().decode(ImageServer.self, from: data)
                print("response is :")
                print(response.description)
                self.setToUserDefaults(value: image2.image?.path, key: "profile_image")
              try  DispatchQueue.main.sync {
                self.profileImageView.layer.borderWidth = 0
                self.profileImageView.layer.masksToBounds = false
                
               self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
                self.profileImageView.clipsToBounds = true
                
                print("--UPLOADIMAGE \(image2)")
                    let urlString = try ApiRouts.Web + (image2.image?.path)!
                    var url = URL(string: urlString)
                    self.profileImageView.sd_setImage(with: url!, completed: nil)
                }
            }catch let error {
                print(error)
            }
            print(response.data)
            print(response.data.description)
            if response.error != nil {
                print(response.error)
            }
            //do things...
            
        }
        
    }
    
    
    @IBAction func memberMenuTapped(_ sender: Any) {
        if isMemberMenuShowing {
             menuButton.setImage(UIImage(named: menuIcon), for: .normal)
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            memberLeadingConstraints.constant = 190
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        } else {
            if isFilterShowing {
                leadingConstraint.constant = -199
                isFilterShowing = !isFilterShowing
                 UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            }
            
            menuButton.setImage(UIImage(named: "arrow right"), for: .normal)
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            memberLeadingConstraints.constant = 0
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        }
     
        isMemberMenuShowing = !isMemberMenuShowing
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
        let profile_image = defaults.string(forKey: "profile_image")
        let gender = defaults.string(forKey: "gender")
        
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == true{
                self.isLogged = true
                self.id = id
                self.phoneNumberStackView.isHidden = true
                self.chatHeaderStackView.isHidden = false
                self.profileImageView.layer.borderWidth = 0
                self.profileImageView.layer.masksToBounds = false
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
                self.profileImageView.clipsToBounds = true
                MyVriables.currentMember = Member(email: email, phone: phone, id: id)

            if first != nil && last != nil {
                self.memberNameLbl.text = (first)! + " " + (last)!
            }
            
            if phone != nil {
                self.memberPhoneLbl.text = (phone)!
            }
            if gender != nil {
                if (gender)! == "male" {
                    self.memberGenderLbl.text = "Male"
                }else {
                    self.memberGenderLbl.text = "Female"

                }
            }
            
            if profile_image != nil {
                let urlString = try ApiRouts.Web + (profile_image)!
                var url = URL(string: urlString)
                if url != nil {
                    self.profileImageView.sd_setImage(with: url!, completed: nil)
                }
                
            }
            
            self.sort = standart_sort
            if #available(iOS 11.0, *) {
                self.myGroupsBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
            } else {
                // Fallback on earlier versions
                self.myGroupsBt.setTitleColor(Colors.PrimaryColor, for: .normal)
            }
            self.hasLoadMore = true
            self.getGroupsByFilter()
            
            
        }else{
            
          self.getSwiftGroups()
            
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
    
    func setNotificationTap(){
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("notificationsTepped"))
        notificationsImageView.isUserInteractionEnabled = true
    notificationsImageView.addGestureRecognizer(singleTap)
    }
    @objc func notificationsTepped(){
        performSegue(withIdentifier: "showNotifications", sender: self)
        

    }
    
    @objc func refreshData(){
        print("refresh is loading")
        self.page = 1
        self.myGrous = []
        self.hasLoadMore = true
        self.tableView.reloadData()
        if self.isLogged {
            ARSLineProgress.show()
                self.getGroupsByFilter()
            
            
        }else{
            
                self.getSwiftGroups()
            
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
        if self.countryPrefLable.text! == "+972" {
            if self.phoneNumberFeild.text!.count > 4 && self.phoneNumberFeild.text![0...0] == "0" {
                self.phoneNumberFeild.text!.remove(at: self.phoneNumberFeild.text!.startIndex)
               self.phoneNumber = "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"
                print("yes im inside \(self.phoneNumber)")

               
            }
        }
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            let params = ["phone": self.phoneNumber]
            
            HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
                if response.error != nil {
                    print("error \(response.error?.localizedDescription)")
                    return
                }
                print ("successed")
                DispatchQueue.main.sync {
                    self.showPinDialog()
                }
                //do things...
            }
            
          
            
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")

            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    
    
    fileprivate func showPinDialog() {
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created")
        
        PinAlert.addTextField { (textField) in
            textField.placeholder = "1234"
            
        }
        print ("pin created")
        
        PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
            
            print ("pin 1")
            
            let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
            print ("pin 2")
            
            self.PINCODE = textField?.text
            print("PIN CODE : \((textField?.text)!)")
            var params: [String: Any] = [:]
            
            //                        if self.countryPrefLable.text![0...4] == "+972" {
            //                            if self.countryPrefLable.text![5]
            //                             params = ["code": (textField?.text)!, "phone": "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"]
            //                        }else{
            //                             params = ["code": (textField?.text)!, "phone": "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"]
            //                        }
            params = ["code": (textField?.text)!, "phone": "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"]
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                if response.error != nil {
                    print(response.error)
                    return
                }
                print(response.description)
                do{
                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    
                    self.currentMember = member
                    self.setToUserDefaults(value: true, key: "isLogged")
                    //  print(self.currentMember?.profile!)
                    self.setToUserDefaults(value: self.currentMember?.profile?.member_id!, key: "member_id")
                    self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                    self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                    self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                    self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                    self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                    self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                    
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                        self.myGrous = []
                        self.page = 1
                        self.tableView.reloadData()
                        self.checkCurrentUser()
                        //                                    self.phoneNumberStackView.isHidden = true
                        //                                    self.chatHeaderStackView.isHidden = false
                        //                                }
                    }
                    MyVriables.isMember = true
                    
                    
                }
                catch {
                    print("catch error")
                    self.phoneNumberStackView.isHidden = false
                    self.chatHeaderStackView.isHidden = true
                    self.setToUserDefaults(value: false, key: "isLogged")
                    
                }
                
            }
            
            
            
            
        }))
        print ("pin after ok ")
        
        PinAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCLE", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
            
        }))
        print ("pin after no ")
        
        self.present(PinAlert, animated: true, completion: nil)
        
        print ("pin after present ")
    }
    
    
    
    // get groups reqeust: by page
    
    func getSwiftGroups(){
        print("request PAGE = \(self.page)")
        let params = ["page": self.page]
        var groups: [TourGroup]?
        HTTP.GET(ApiRouts.AllGroupsRequest + "?page=\(self.page)") { response in
            print(ApiRouts.AllGroupsRequest)
            //do things...
          //  print(response.description)
            let data = response.data
//            print(response)

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

              //  print(self.myGrous.count)
            }
            catch {
                
            }
            
        }
    }
    
    func getGroupsByFilter() {
        print("request PAGE = \(self.page)")

        var groups: [TourGroup]?
        let withoutFilter = "/api/groups/members/\(self.id)?page=\(self.page)&sort=\(self.sort)"
        let withRole = "/api/groups/members/\(self.id)?page=\(self.page)&role=group_leader&sort=\(self.sort)"
        let withFilter = "/api/groups?member_id=\(self.id)&page=\(self.page)&filter=\(self.filter)&sort=\(self.sort)"
        let allGroupsFilter = "/api/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)"
        let searchUrl  = "/api/groups?member_id=\(self.id)?page=\(self.page)&sort=\(self.sort)&search=\(self.search)"
            ////url = Constants.SERVERIP + "api/groups?member_id="+userId+"&search=" + arrayForFilter[2]
           // +"&page="+page+"&sort=created_at&order=desc";
        var lastFilter: String
        if filter == "all" {
            lastFilter = allGroupsFilter
        }
        else if filter == "search" {
            lastFilter = searchUrl
        }
        else if filter == "leader" {
            lastFilter = withRole
        }
        else if filter == "no-filter" {
            lastFilter = withoutFilter
        }else{
            lastFilter = withFilter
        }
        HTTP.GET(ApiRouts.Web+lastFilter) { response in
            if ARSLineProgress.shown == true {
                ARSLineProgress.hide()
            }
            if let error = response.error {
                print(error)
                  ARSLineProgress.hide()
            }
            let data = response.data
            
            do {
                
                let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                groups = groups2.data!
                print("------------- \(lastFilter)  Page: \(self.page) groups count: \(groups?.count)")

                
                if groups2.last_page! < self.page {

                    print("has Load more is false now  because goups count is : \(groups?.count)")
                    self.hasLoadMore = false
                    return
                }else {
                    print("has Load more is true now  because goups count is : \(groups?.count)")

                }
                
                
                
                DispatchQueue.main.sync {
                    for group in groups! {
                        if !self.myGrous.contains(where: { (tGroup) -> Bool in
                            return tGroup.id == group.id
                        }) {
                            self.myGrous.append(group)
                        }
                    }
                    //   self.myGrous = groups!
                    self.tableView.reloadData()
                    if self.refresher.isRefreshing{
                        self.refresher.endRefreshing()
                    }
                      ARSLineProgress.hide()
                    self.page += 1
                }
            }
            catch let error  {
                print("im in catch \(error)")
                ARSLineProgress.hide()
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
            if isLogged {
                print("is Logged - has Loaded More true")
                self.getGroupsByFilter()
                
            }else{
                print("Not  Logged - has Loaded More false")
                self.getSwiftGroups()
                
            }
           
        }
    }
    
    // tableview: tableview count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("hi \(myGrous.count)")
        return isLogged ? self.myGrous.count+1 : self.myGrous.count
    }
    
    
    // tableview: return the cell
    
    fileprivate func setGroupItmes(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        //var index = isLogged ? indexPath.row -1 : indexPath
          var currentIndex = isLogged ? indexPath.row-1 : indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        cell.viewInfo.tag = currentIndex
        cell.viewInfo.addTapGestureRecognizer(action: ShowModel)
        if self.myGrous[currentIndex].image != nil{
            print("IMAGESTATUS - in if ")
            
            do{
                var urlString: String = try ApiRouts.Web + (self.myGrous[currentIndex].image)!
                if self.myGrous[currentIndex].image != nil{
                    print(urlString)
                    
                }
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    print("image:  \(String(describing: url)) , belongs to : \(self.myGrous[currentIndex].translations?[0].title!)")
                    cell.imageosh.sd_setImage(with: url, placeholderImage: UIImage(named: "Group Placeholder"), completed: nil)
                    
                }else {
                    cell.imageosh.image = UIImage(named: "Group Placeholder")
                    print("IMAGESTATUS - in out of let - for group -  \(self.myGrous[currentIndex].translations?[0].title!) , urlString: \(urlString)")
                    
                }
                
            }
            catch{
                print("in the catch with image \((self.myGrous[currentIndex].title)!)")
                cell.imageosh.image = UIImage(named: "Group Placeholder")
                
            }
        } else {
            print("IMAGESTATUS - in else ")
            
            cell.imageosh.image = UIImage(named: "Group Placeholder")
        }
        cell.startDayLbl.text = getStartDate(date: self.myGrous[currentIndex].start_date!)
        cell.totalDaysLbl.text = "\(getTotalDays(start: self.myGrous[currentIndex].start_date!, end: self.myGrous[currentIndex].end_date!))"
        if self.myGrous[currentIndex].max_members != nil{
            cell.totalMembersLbl.text = "\(self.myGrous[currentIndex].max_members!)"
        }else{
            if self.myGrous[currentIndex].target_members != nil {
                cell.totalMembersLbl.text = "\(self.myGrous[currentIndex].target_members!)"
            }
        }
        // if company
        if self.myGrous[currentIndex].is_company == 0 {
            
            cell.groupLeaderLbl.text = self.myGrous[currentIndex].group_leader_first_name! + " " + self.myGrous[currentIndex].group_leader_last_name!
            
            if self.myGrous[currentIndex].group_leader_image != nil{
                do{
                    
                    let urlString = try ApiRouts.Web + (self.myGrous[currentIndex].group_leader_image)!
                    var url = URL(string: urlString)
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "default user"), completed: nil)
                    }
                }
                catch let error{
                }
                
            }
            cell.groupLeaderImageView.layer.cornerRadius = cell.groupLeaderImageView.frame.size.width / 2;
            cell.groupLeaderImageView.clipsToBounds = true;
            cell.groupLeaderImageView.layer.borderWidth = 1.0
            cell.groupLeaderImageView.layer.borderColor = UIColor.gray.cgColor
        } // if just group leader
        else{
            if self.myGrous[currentIndex].group_leader_company_image != nil{
                
                do{
                    let urlString = try ApiRouts.Web + (self.myGrous[currentIndex].group_leader_company_image)!
                    var url = URL(string: urlString)
                    //                        cell.groupLeaderImageView.layer.borderWidth = 0
                    //                        cell.groupLeaderImageView.layer.masksToBounds = false
                    //                        cell.groupLeaderImageView.layer.cornerRadius = cell.groupLeaderImageView.frame.height/2
                    //                        cell.groupLeaderImageView.clipsToBounds = true
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "default user"), completed: nil)
                        
                    }
                }catch {
                    
                }
            }
            cell.groupLeaderImageView.layer.borderWidth = 0
            cell.groupLeaderImageView.layer.cornerRadius = 0;
            cell.groupLeaderImageView.clipsToBounds = false;
         //   cell.groupLeaderLbl.text =   self.myGrous[currentIndex].group_leader_company_name!
        }
        cell.selectionStyle = .none
        
        if self.myGrous[currentIndex].translations?.count != 0 {
            cell.groupLabel.text = self.myGrous[currentIndex].translations?[0].title
            
        }else{
            cell.groupLabel.text = self.myGrous[currentIndex].title
        }
        if self.myGrous[currentIndex].translations?.count != 0
        {
            cell.descriptionLbl.text = self.myGrous[currentIndex].translations?[0].description
        }
        if self.myGrous[currentIndex].registration_end_date != nil {
            if isClosed(date: self.myGrous[currentIndex].registration_end_date!)
            {
                cell.timeOutIcon.isHidden = false
            }
            else{
                cell.timeOutIcon.isHidden = true
            }
        }
        if (self.myGrous[currentIndex].role) == nil
        {
            cell.inviteIcon.isHidden = true
            cell.memberIcon.isHidden = true
            cell.leaderIcon.isHidden = true
            
            if (self.myGrous[currentIndex].open)! == true
            {
                cell.openIcon.isHidden = false
                cell.privateIcon.isHidden = true
            }
            else{
                cell.openIcon.isHidden = true
                cell.privateIcon.isHidden = false
            }
            
        }
        else{
            if (self.myGrous[currentIndex].open)! == true
            {
                cell.openIcon.isHidden = false
                cell.privateIcon.isHidden = true
            }
            else{
                cell.openIcon.isHidden = true
                cell.privateIcon.isHidden = false
            }
            if (self.myGrous[currentIndex].role)! == "observer"
            {
                cell.inviteIcon.isHidden = false
                cell.memberIcon.isHidden = true
                cell.leaderIcon.isHidden = true
                
            }
            else
            {
                if (self.myGrous[currentIndex].role)! == "member"
                {
                    cell.inviteIcon.isHidden = true
                    cell.memberIcon.isHidden = false
                    cell.leaderIcon.isHidden = true
                }
                else
                {
                    if (self.myGrous[currentIndex].role)! == "group_leader"
                    {
                        cell.inviteIcon.isHidden = true
                        cell.memberIcon.isHidden = true
                        cell.leaderIcon.isHidden = false
                    }
                    else
                    {
                        print("role is \((self.myGrous[currentIndex].role)!))")
                        cell.inviteIcon.isHidden = true
                        cell.memberIcon.isHidden = true
                        cell.leaderIcon.isHidden = true
                    }
                    
                }
                
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLogged
        {
            if indexPath.row != 0 {
                return setGroupItmes(tableView, indexPath)
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchGroupViewCell
                cell.search_bar.delegate = self
                cell.search_bar.searchBarStyle = .minimal;
                return cell
            }
        }
        else{
          return setGroupItmes(tableView, indexPath)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text)
        if (searchBar.text)! != "" {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        filter = "search"
        sort = "created_at&order=desc"
        search = (searchBar.text)!
        search = search.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        searchBar.text = ""
        ARSLineProgress.hide()
        self.refreshData()
      
        
        view.endEditing(true)
        }
    }

 
    
    func ShowModel() {
         self.performSegue(withIdentifier: "showInfo", sender: self)
    }
    func isClosed(date: String) -> Bool{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("DDDAAATTEEE: "+formatter.string(from: currentDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatter.date(from: date)!
        print("REG END DATE: "+dateFormatter.string(from: date2))
        var days = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day! as? Int
        var hours = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour! as? Int
        print("days: \(days!) , hours: \(hours!)")
        if days! < 0 || hours! < 0 {
            return true
        }
        else{
           return false
        }
        
        //   print(date)
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
        
        var currentIndex = isLogged ? indexPath.row-1 : indexPath.row
        if self.isFilterShowing {
                self.leadingConstraint.constant = -199
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                self.isFilterShowing = !self.isFilterShowing
            }
       else  if isMemberMenuShowing {
            menuButton.setImage(UIImage(named: menuIcon), for: .normal)
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            memberLeadingConstraints.constant = 190
            isMemberMenuShowing = !isMemberMenuShowing
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        }
        else {
            
            let isOpen : Bool = self.myGrous[currentIndex].open!
            var role : String? = self.myGrous[currentIndex].role
            if role == nil {
                role = "null"
            }
            print("\(role!) \(isOpen)")

            if role!  == "null" {
                if isOpen {
                    MyVriables.currentGroup = self.myGrous[currentIndex]
                    self.performSegue(withIdentifier: "groupDetailsBar", sender: self)
                }else {
                    showCloseAlert()
                }
            }else{
                MyVriables.currentGroup = self.myGrous[currentIndex]
                self.performSegue(withIdentifier: "groupDetailsBar", sender: self)
            }
        }
        
        
        
        
    }
    func showCloseAlert(){
        let alert = UIAlertController(title: "Closed group, please contact the group leader in order to join this group.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    // height for each section
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.cellSpacingHeight
    }
    

    func getStartDate(date: String) -> String{
        let monthString: String = getMonthName(month: date[5...6])
        let day: String = date[8...9]
        return """
               \(day)
               \(monthString)
               """
    }

    // months from numbers to string
    func getMonthName(month: String) -> String{
        switch month {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "Jun"
        case "06":
            return "Jul"
        case "07":
            return "Aug"
        case "08":
            return "Sep"
        case "09":
            return "Oct"
        case "10":
            return "Nov"
        case "11":
            return "Dec"
        case "12":
            return "Feb"
        default:
            return "null"
        }
    }
    // get the total days between two dates
    func getTotalDays(start: String,end: String) -> String{
        // format the start date
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = startDateFormatter.date(from: start)!
        // format the end date
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "yyyy-MM-dd"
        let endDate = endDateFormatter.date(from: end)!

        var days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! as? Int
        return "\(days!)"
    }
    
    
    func closeFilterSlide(){
        leadingConstraint.constant = -199
        isFilterShowing = !isFilterShowing
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
    }
    func showToast(_ message: String,_ duration: Double){
        var style = ToastStyle()
        // this is just one of many style options
        style.messageColor = .white
        // present the toast with the new style
        self.view.makeToast(message, duration: duration, position: .bottom, style: style)
    }
    
    
    /********* Filter Click Actions **********/
    
    @IBAction func myGroupsTapped(_ sender: Any) {
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        
        if #available(iOS 11.0, *) {
            self.myGroupsBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.myGroupsBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        search = ""
        sort = standart_sort
        filter = "no-filter"
       // showToast("My Message", 3.0)
        self.refreshData()
        
        
        
    }
    func refreshList(){
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        if #available(iOS 11.0, *) {
            self.myGroupsBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.myGroupsBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        sort = standart_sort
        filter = "no-filter"
       // showToast("My Message", 3.0)
        self.refreshData()
    }
    
    @IBAction func managamentTapped(_ sender: Any) {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        if #available(iOS 11.0, *) {
            self.managamentBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.managamentBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        search = ""
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
       self.closeFilterSlide()
        filter = "leader"
        sort = "created_at&order=desc"
        self.refreshData()
    }
    
    
    
    @IBAction func allgroupsTouchOut(_ sender: Any) {
    print("allgroups touch ")
    }
    
    @IBAction func publicTapped(_ sender: Any) {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        if #available(iOS 11.0, *) {
            self.publicGroupsbt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.publicGroupsbt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        search = ""
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        filter = "open"
        sort = "created_at&order=desc"
        self.refreshData()
    }
    
    @IBAction func allGroupsTapped(_ sender: Any) {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        search = ""
        if #available(iOS 11.0, *) {
            self.allGroupsBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.allGroupsBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        filter = "all"
        sort = "created_at&order=desc"
        self.refreshData()
    }
    
    @IBAction func oneDayTapped(_ sender: Any) {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        search = ""
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
        if #available(iOS 11.0, *) {
            self.oneDayBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.oneDayBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        filter = "day"
        sort = "created_at&order=desc"
        self.refreshData()
    }
    @IBAction func multiDaysTapped(_ sender: Any) {
        self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
        search = ""
        self.managamentBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        if #available(iOS 11.0, *) {
            self.multiDaysBt.setTitleColor(UIColor(named: "Primary"), for: .normal)
        } else {
            // Fallback on earlier versions
            self.multiDaysBt.setTitleColor(Colors.PrimaryColor, for: .normal)
        }
        self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
        filter = "days"
        sort = "created_at&order=desc"
        self.refreshData()
        
    }
    /********* Sort Click Actions **********/

    @IBAction func createdSortTapped(_ sender: Any) {
        
    }
    @IBAction func departureTapped(_ sender: Any) {
        
    }
    
    @IBAction func totalTapped(_ sender: Any) {
        
    }
    
    /********* Clear Filter Action **********/

    @IBAction func clearFilterTapped(_ sender: Any) {
        
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        
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

