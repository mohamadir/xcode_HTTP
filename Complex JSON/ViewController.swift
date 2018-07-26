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
import SwiftEventBus
import Alamofire
import AlamofireImage
import PhoneNumberKit
import CountryPickerView
import TTGSnackbar
import Kingfisher
import FBSDKLoginKit
import FBSDKCoreKit
import FTPopOverMenu_Swift
import PopoverSwift

//import FTPopOverMenu_Swift



/***********************************************      VIEW CONTROLLER     *************************************************************/


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,  MRCountryPickerDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    var menuOptionNameArray = ["All groups", "My groups", "Public groups", "One day groups","Multi days groups"]
    
    var menuOptionImageNameArray = ["", "", "", "",""]
    @IBOutlet var pickerFacebookView: UIView!
    // header views
    var clickes: [Bool] =  [false,true,false,false,false]
    var contryCodeString : String = ""
    var contryCode : String = ""
    @IBOutlet var menuView: UIView!
    @IBOutlet weak var phoneFacebookLbl: UITextField!
    var isFacebookGdpr: Bool = false
    @IBOutlet weak var phoneRegisterView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var facebookRegisterView: UIView!
    @IBOutlet weak var fPickerView: CountryPickerView!
    var PINCODE: String?
    var facebookMember : FacebookMember?
    var phoneNumber: String?
    ///////// GROUP SETTINGS
    var isLoading: Bool = false
    //import MRCountryPicker
    /********  VIEWS ***********/
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var countyCodePickerView: CountryPickerView!
    @IBOutlet var countryPicker: MRCountryPicker!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var countryPrefLable: UILabel!
    @IBOutlet var chatImageView: UIImageView!
    @IBOutlet var chatHeaderStackView: UIView!
    @IBOutlet var phoneNumberStackView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var phoneNumberFeild: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var filterView: UIView!
    @IBOutlet var memberMenuView: UIView!
    @IBOutlet var memberNameLbl: UILabel!
    @IBOutlet var memberPhoneLbl: UILabel!
    @IBOutlet var memberGenderLbl: UILabel!
    @IBOutlet var notificationsImageView: UIImageView!
    @IBOutlet var noGroupsView: UIView!
    @IBOutlet var InboxCounterView: DesignableView!
    @IBOutlet var ChatCounterView: DesignableView!
    @IBOutlet var countryCodeVeiw: UIView!
    
    @IBOutlet var myGroupByPhoneView: UIView!
    @IBOutlet var chatView: UIView!
    @IBOutlet var inboxView: UIView!
    @IBOutlet var inboxCounterLbl: UILabel!
    @IBOutlet var chatCounterLbl: UILabel!
    
    @IBOutlet var noGroupText: UILabel!
    /********* Filter Buttons **********/
    @IBOutlet var myGroupsBt: UIButton!
    @IBOutlet var managamentBt: UIButton!
    @IBOutlet var publicGroupsbt: UIButton!
    @IBOutlet var oneDayBt: UIButton!
    @IBOutlet var multiDaysBt: UIButton!
    @IBOutlet var createdSortBt: UIButton!
    @IBOutlet var allGroupsBt: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    /****** Sort Buttons ************/
    
    @IBOutlet var DepratureSortBt: UIButton!
    @IBOutlet var totalDaysBt: UIButton!
    @IBOutlet var notficationLbl: UILabel!
    @IBOutlet var notficationView: UIView!
    @IBOutlet var notficicationIcon: UIImageView!
    

    /********* CONSTRAINTS **********/
  
    @IBOutlet var memberLeadingConstraints: NSLayoutConstraint!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    @IBAction func editProfile(_ sender: Any) {
         performSegue(withIdentifier: "showModal", sender: self)
        //showModal
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
      
        
    }
    @IBAction func savePhone(_ sender: Any) {
        //api/members/{member_id}/phone?no_password=true
        DispatchQueue.global(qos: .userInitiated).async {
            // Do long running task here
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                if self.isValidPhone(phone: self.contryCodeString+self.phoneFacebookLbl.text!)
                {
                    
                    print("\(self.contryCodeString)\(self.phoneNumberFeild.text!)")
                    self.phoneNumber = self.contryCodeString+self.phoneFacebookLbl.text!
                    if self.contryCodeString == "+972" {
                        if self.phoneFacebookLbl.text!.count > 4 && self.phoneFacebookLbl.text![0...0] == "0" {
                            self.phoneFacebookLbl.text!.remove(at: self.phoneFacebookLbl.text!.startIndex)
                            self.phoneNumber = "\(self.contryCodeString)\(self.phoneFacebookLbl.text!)"
                            print("yes im inside \(self.phoneNumber)")
                            
                            
                        }
                    }
                    let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.phoneNumber!)", preferredStyle: .alert)
                    
                    
                    VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
                        let defaults = UserDefaults.standard
                        let id = defaults.integer(forKey: "member_id")
                        print(ApiRouts.Web + "/api/members/\(id)/phone?no_password=true")
                        
                        HTTP.PUT(ApiRouts.Web + "/api/members/\(id)/phone?no_password=true", parameters: ["phone" : self.phoneNumber, "country_code" : self.contryCodeString]) { response in
                            if response.error != nil {
                                DispatchQueue.main.async {
                                    let snackbar = TTGSnackbar(message: "The phone number you selected is already linked to a different account.", duration: .middle)
                                    snackbar.icon = UIImage(named: "AppIcon")
                                    snackbar.show()
                                }
                                print("error \(response.error?.localizedDescription)")
                                return
                            }
                            print ("successed")
                            DispatchQueue.main.sync {
                                //
                                self.setToUserDefaults(value: self.phoneNumber, key: "phone")
                                print("Phone number is \(self.phoneNumber)")
                                self.checkCurrentUser()
                                
                                
                            }
                            //do things...
                        }
                        
                        
                        
                    }))
                    VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
                        print("no")
                        
                        
                        
                    }))
                    self.present(VerifyAlert, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    @IBAction func privacyClick(_ sender: Any) {
        menuImage.image = UIImage(named: menuIcon)
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        self.memberLeadingConstraints.constant = 190
         performSegue(withIdentifier: "showPrivacy", sender: self)
    }
    @IBOutlet var settingClick: UIButton!
    /******* VARIABLES *********/
    var menuIcon: String = "iMenuIcon"
    var myGrous: [TourGroup] = []
    var currentGroup: TourGroup?
    @IBOutlet weak var fbBt: UIButton!
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
    
    @IBOutlet var currentView: UIView!
    // sort & filter variables
    var filter: String = "no-filter"
    var sort: String = ""
    var isLogged: Bool = false
    var id: Int = -1
    var isMemberMenuShowing: Bool = false
    
    @IBAction func filterClick(_ sender: Any) {
        print("Im clicked")
        let config = FTConfiguration.shared
        config.backgoundTintColor = UIColor.white
        config.menuWidth = 220
        config.menuSeparatorColor = UIColor.white
        config.menuRowHeight = 60
        config.cornerRadius = 6
        let cellConfi = FTCellConfiguration()
        cellConfi.textColor = UIColor.black
        cellConfi.textFont = UIFont.systemFont(ofSize: 20)
        var cellConfis = Array(repeating: cellConfi, count: 5)
        let cellConfi1 = FTCellConfiguration()
        cellConfi1.textFont = UIFont.systemFont(ofSize: 20)
        let PrimaryColor : UIColor = UIColor(rgb: 0xC1B46A)
        cellConfi1.textColor = PrimaryColor
        cellConfis[1] = cellConfi1
        FTPopOverMenu.showForSender(sender: sender as! UIView, with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, cellConfigurationArray: cellConfis, done: { (selectedIndex) in
            print(selectedIndex)
        }) {
            print("cancel")
        }
    }
    @IBAction func onFilterTapped(_ sender: Any) {
        
//        let config = FTConfiguration.shared
//        config.backgoundTintColor = UIColor.white
//        config.menuWidth = 220
//        config.menuSeparatorColor = UIColor.white
//        config.menuRowHeight = 60
//        config.cornerRadius = 6
//        let cellConfi = FTCellConfiguration()
//        cellConfi.textColor = UIColor.black
//        cellConfi.textFont = UIFont.systemFont(ofSize: 20)
//        var cellConfis = Array(repeating: cellConfi, count: 5)
//        let cellConfi1 = FTCellConfiguration()
//        cellConfi1.textFont = UIFont.systemFont(ofSize: 20)
//        let PrimaryColor : UIColor = UIColor(rgb: 0xC1B46A)
//        cellConfi1.textColor = PrimaryColor
//        cellConfis[1] = cellConfi1
//        FTPopOverMenu.showForSender(sender: sender as! UIView, with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, cellConfigurationArray: cellConfis, done: { (selectedIndex) in
//            print(selectedIndex)
//        }) {
//            print("cancel")
//        }
//        if isFilterShowing {
//            leadingConstraint.constant = -199
//           // UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//
//        }
//        else{
//
//            if isMemberMenuShowing {
//                menuImage.image = UIImage(named: menuIcon)
//                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//                memberLeadingConstraints.constant = 190
//                isMemberMenuShowing = !isMemberMenuShowing
//                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//            }
//            leadingConstraint.constant = 0
//           // UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//
//        }
//
//       isFilterShowing = !isFilterShowing
    }
    
    @IBAction func settingsClick(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: sender)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    func subScribe(){
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().subscribe(toTopic: "/topics/a123458")
    }
    func downloadfile(){
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(
            "https://www.w3schools.com/w3images/lights.jpg",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
            }).response(completionHandler: { (DefaultDownloadResponse) in
                
                print("DefaultDownloadResponse \(DefaultDownloadResponse.destinationURL)")
                //here you able to access the DefaultDownloadResponse
                //result closure
            })
    }
  
    func setCheck(isChecked : Bool, chekAll : Bool, postion : Int){
        var params: [String: Any]
        params = ["push_notifications": isChecked]
        HTTP.PUT(ApiRouts.Web +  "/api/members/\((MyVriables.currentMember?.id)!)/gdpr", parameters: params) {
            response in
            if response.error != nil {
                //print(response.error)
                return
            }
            do {
                let  gdprUpdate : GdprUpdate = try JSONDecoder().decode(GdprUpdate.self, from: response.data)
                MyVriables.currentMember?.gdpr = GdprStruct(profile_details: (gdprUpdate.gdpr?.profile_details)!, phone_number: (gdprUpdate.gdpr?.phone_number)!, groups_relations: (gdprUpdate.gdpr?.groups_relations)!, chat_messaging: (gdprUpdate.gdpr?.chat_messaging)!, pairing: (gdprUpdate.gdpr?.pairing)!, real_time_location: (gdprUpdate.gdpr?.real_time_location)!, files_upload: (gdprUpdate.gdpr?.files_upload)!, push_notifications: (gdprUpdate.gdpr?.push_notifications)!, rating_reviews: (gdprUpdate.gdpr?.rating_reviews)!, group_details: (gdprUpdate.gdpr?.profile_details)!, billing_payments : true, checkAllSwitch: true)
                DispatchQueue.main.async {
                    if isChecked == false
                    {
                        
                        self.notficicationIcon.image = UIImage(named: "pushNotiOff")
                        self.notficationLbl.alpha = 0.3
                        UIApplication.shared.unregisterForRemoteNotifications()
                    }
                    else
                    {
                        if isChecked == true{
                            self.notficicationIcon.image = UIImage(named: "pushNotiOn")
                            self.notficationLbl.alpha = 1
                            SwiftEventBus.post("shouldRefreshGdpr")
                            
                        }
                    }
                   
                }
               
            }
            catch {
                
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        print("Viewstatus Did appeear ")
        if MyVriables.shouldRefresh {
            refreshList()
            MyVriables.shouldRefresh = false
        }
       
    }
    fileprivate func swiftEventFunc() {
        SwiftEventBus.onMainThread(self, name: "changeProfileInfo") { result in
                self.checkCurrentUser()
            
        }
        
       
        SwiftEventBus.onMainThread(self, name: "changeProfileInfoHeader") { result in
            print("hihihihihihihihihii")
            self.checkCurrentUser()

        }
        
        SwiftEventBus.onMainThread(self, name: "changeProfileInfooo") { result in
            DispatchQueue.main.async {
                self.page = 1
                self.myGrous = []
                self.hasLoadMore = true
                self.tableView.reloadData()
                print("Refresh groups without filter")
                self.phoneNumberFeild.text = ""
                self.phoneNumberStackView.isHidden = false
                self.registerView.isHidden = false
                self.chatHeaderStackView.isHidden = true
                self.isLogged = false
                self.myGroupByPhoneView.isHidden = true
                print("IS logged = false")
                self.getSwiftGroups()
                
            }
        }
        SwiftEventBus.onMainThread(self, name: "counters") { (result) in
            print("CHAT-COUNTER RECEIVED IN VIEW CONTROLLER ")
            self.setBadges()
        }
        SwiftEventBus.onMainThread(self, name: "refreshGroups") { result in
            print("im Here from Gdpr and flags is ")
            if result?.object != nil {
                self.facebookMember = result?.object as! FacebookMember
                self.isFacebookGdpr = true
                self.regstirFacebook(facebookMember: self.facebookMember!, isGdpr:  self.isFacebookGdpr)
                
            }else {
                self.showPinDialogGdpr()
                
            }
            
        }
        SwiftEventBus.onMainThread(self, name: "refreshData") { result in
            print("im Here from Gdpr")
            self.refreshList()
        }
    }
    @objc func pressButton(_ sender: UIButton){
            
            if isMemberMenuShowing {
                menuImage.image = UIImage(named: menuIcon)
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                memberLeadingConstraints.constant = 190
                isMemberMenuShowing = !isMemberMenuShowing
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            }
        isFilterShowing = !isFilterShowing
        var items : [PopoverItem] = []
        var controller: PopoverController?
        var item1,item0,item2,item3,item4 : PopoverItem?
        item0 = PopoverItem(title: "All groups", titleColor: self.clickes[0] == true ? Colors.PrimaryColor : UIColor.black, image : UIImage(named: "")) { debugPrint($0.title)
            self.clickes[0] = true
            self.clickes[1] = false
            self.clickes[2] = false
            self.clickes[3] = false
            self.clickes[4] = false
            self.filter = "all"
            self.sort = "created_at&order=desc"
            self.refreshData()
        }
        item1 = PopoverItem(title: "My groups", titleColor: self.clickes[1] == true ? Colors.PrimaryColor : UIColor.black, image : UIImage(named: "")) { debugPrint($0.title)
            self.clickes[0] = false
            self.clickes[2] = false
            self.clickes[3] = false
            self.clickes[1] = true
            self.clickes[4] = false
            self.search = ""
            self.sort = self.standart_sort
            self.filter = "no-filter"
            // showToast("My Message", 3.0)
            self.refreshData()
        }
         item2 = PopoverItem(title: "Public groups", titleColor: self.clickes[2] == true ? Colors.PrimaryColor : UIColor.black, image : UIImage(named: "")) { debugPrint($0.title)
            self.clickes[0] = false
            self.clickes[1] = false
            self.clickes[3] = false
            self.clickes[2] = true
            self.clickes[4] = false
            self.search = ""
            self.filter = "open"
            self.sort = "created_at&order=desc"
            self.refreshData()
        }
         item3 = PopoverItem(title: "One day groups", titleColor: self.clickes[3] == true ? Colors.PrimaryColor : UIColor.black, image: UIImage(named: "")) { debugPrint($0.titleColor)
            print("asd")
            self.clickes[0] = false
            self.clickes[1] = false
            self.clickes[2] = false
            self.clickes[3] = true
            self.clickes[4] = false
            self.search = ""
            self.filter = "day"
            self.sort = "created_at&order=desc"
            self.refreshData()
        }
         item4 = PopoverItem(title: "Multi days groups", titleColor: self.clickes[4] == true ? Colors.PrimaryColor : UIColor.black, image: UIImage(named: "")) { debugPrint($0.title)
            self.clickes[0] = false
            self.clickes[1] = false
            self.clickes[2] = false
            self.clickes[3] = false
            self.clickes[4] = true
            self.filter = "days"
            self.sort = "created_at&order=desc"
            self.refreshData()
        }

         items = [item0!, item1!, item2!, item3!, item4!]
        controller = PopoverController(items: items, fromView: filterButton, direction: .down, style: .normal)
        popover(controller!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swiftEventFunc()
      
        print("Viewstatus Did load ")

        filterButton.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside) //<- use `#selector(...)`
        
        fbBt.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
     
        //refreshData
        // Hide the navigation bar on the this view controller
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
      
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        
        if isLogged != true{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if let window = UIApplication.shared.delegate?.window {
                    if var viewController = window?.rootViewController {
                        if(viewController is UINavigationController){
                            viewController = (viewController as! UINavigationController).visibleViewController!

                        }

                        print(viewController)
                        if viewController is ViewController
                        {
                            if self.phoneNumberFeild.text != nil && self.phoneNumberFeild.text != "" {
                                
                            }
                            else {
                                self.performSegue(withIdentifier: "showRegstirModal", sender: self)
                            }
                        }
                    }
                }

            }
        }
        phoneRegisterView.addTapGestureRecognizer {
            self.registerView.isHidden = true
            self.phoneNumberStackView.isHidden = false
            self.chatHeaderStackView.isHidden = true
        }

//        facebookRegisterView.addTapGestureRecognizer {
//            print("Im clicked hereeee from not gdrp")
//            FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
//                if err != nil {
//                    print("Custom FB Login failed:", err)
//                    return
//                }
//
//                self.showEmailAddress()
//            }
//        }
      
        SwiftEventBus.onMainThread(self, name: "facebookLogin") { result in
            self.facebookMember = result?.object as! FacebookMember
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
            
        }
        SwiftEventBus.onMainThread(self, name: "checkMember") { result in
            let phonenumber : String = result?.object as! String
            self.checkIfMember(textFeild: phonenumber, type: "phone",facebookMember : self.facebookMember)

        }
        fPickerView.delegate = self
        fPickerView.delegate = self
        countyCodePickerView.delegate = self
        countyCodePickerView.dataSource = self
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        notficationView.addTapGestureRecognizer {
            if  MyVriables.currentMember?.gdpr?.push_notifications != nil
            {
                if MyVriables.currentMember?.gdpr?.push_notifications! == true
                {
                   self.setCheck(isChecked : false, chekAll : false, postion : 0)
                }
                else
                {
                    self.setCheck(isChecked : true, chekAll : false, postion : 0)
                }
                
                
            }
            
        }

        menuView.addTapGestureRecognizer {
            if self.isMemberMenuShowing {
                self.menuImage.image = UIImage(named: self.menuIcon)
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                self.memberLeadingConstraints.constant = 190
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            } else {
                if self.isFilterShowing {
                    self.leadingConstraint.constant = -199
                    self.isFilterShowing = !self.isFilterShowing
                    UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                }
                
                self.menuImage.image = UIImage(named: "arrow right")
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                self.memberLeadingConstraints.constant = 0
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
            }
            
            self.isMemberMenuShowing = !self.isMemberMenuShowing
        }
        
        fPickerView.showPhoneCodeInView = true
        fPickerView.showCountryCodeInView = false
        countyCodePickerView.showPhoneCodeInView = true
        countyCodePickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        NSLog("roleStatus",  "hihihi")
        
     //   UIApplication.shared.registerForRemoteNotifications()
        
        chatView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showChat", sender: self)
//            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as? ChatViewController {
//
//                if let navigator = self.navigationController {
//                    navigator.pushViewController(viewController, animated: true)
//                }
//            }
           
        }
        inboxView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showNotifications", sender: self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        phoneNumberFeild.keyboardType = .numberPad
        setCountryPicker()
        setRefresher()
        self.checkCurrentUser()
       
        setFilterView()
        setMemberMenuView()
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err)
                return
            }

            self.showEmailAddress()
        }
    }
    func setFilterView(){
        filterView.layer.shadowColor = UIColor.black.cgColor
        filterView.layer.shadowOpacity = 0.5
        filterView.layer.shadowOffset = CGSize.zero
        filterView.layer.shadowRadius = 4
    }
    func showEmailAddress() {
        print("No Error")
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request?.start(completionHandler: { (connection, result, error) in
            
            if error != nil {
                print("Failed to start graph request:", error)
                return
            }
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            print("user indfo \(userInfo)")
            //The url is nested 3 layers deep into the result so it's pretty messy
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                let url = URL(string: imageURL)
                //self.profileImage.kf.setImage(with: url)
                // print("Image utl is \(imageURL)")
                //Download image from imageURL
            }
            
            var facebookMember : FacebookMember = FacebookMember(first_name: userInfo["first_name"] != nil ? userInfo["first_name"] as? String : "", last_name: userInfo["last_name"] != nil ? userInfo["last_name"] as? String : "", facebook_id: userInfo["id"] != nil ? userInfo["id"] as? String : "", facebook_profile_image: ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String)
            self.dismiss(animated: true, completion: nil)
            
            SwiftEventBus.post("facebookLogin", sender: facebookMember)
        })
        
        
        //
        //
        //            print(result)
        //        }
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
        
       // print(photolibrary)
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
        dismiss(animated: true, completion: nil)
        
    }
//    func checkPhotoLibraryPermission() {
//        let photos = PHPhotoLibrary.authorizationStatus()
//        if photos == .notDetermined {
//            PHPhotoLibrary.requestAuthorization({status in
//                if status == .authorized{
//                    ...
//                } else {}
//            })
//        }
//    }
    fileprivate func uploadImageProfile(_ info: [String : Any]) {
    
//        var image: URL
//        if #available(iOS 11.0, *) {
//            print("image info: \(info)" )
//
//            image = info[UIImagePickerControllerImageURL] as! URL
//            print("image info: \(image.isFileURL) ")
//        } else {
//            // Fallback on earlier versions
//            print("image info: \(info)" )
//
//            image = info[UIImagePickerControllerReferenceURL] as! URL
//            print("image info: \(image.isFileURL) ")
//        }
//        ARSLineProgress.show()
//        print("image ref: \(image.standardizedFileURL.absoluteURL)" )
//        let par: [String: Any]
//        if #available(iOS 11.0, *) {
//            par = ["single_image": Upload(fileUrl: image.absoluteURL)]
//        }else {
//            par = ["single_image": Upload(fileUrl: image.standardizedFileURL)]
//
//        }
//        dismiss(animated: true, completion: nil)
//        print("UPLOADIMAGE- url - "+"https://api.snapgroup.co.il/api/upload_single_image/Member/\(MyVriables.currentMember?.id!)/profile")
//        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/profile", parameters: par) { response in
//            print("response is : \(response.data)")
//            ARSLineProgress.hide()
//            let data = response.data
//            do {
//                if response.error != nil {
//                    print("response is : ERROR \(response.error)")
//
//                    return
//                }
//                let  image2 = try JSONDecoder().decode(ImageServer.self, from: data)
//                print("response is :")
//                print(response.description)
//                self.setToUserDefaults(value: image2.image?.path, key: "profile_image")
//                try  DispatchQueue.main.sync {
//                    self.profileImageView.layer.borderWidth = 0
//                    self.profileImageView.layer.masksToBounds = false
//
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
//                    self.profileImageView.clipsToBounds = true
//
//                    print("--UPLOADIMAGE \(image2)")
//                    let urlString = try ApiRouts.Web + (image2.image?.path)!
//                    var url = URL(string: urlString)
//                    self.profileImageView.sd_setImage(with: url!, completed: nil)
//                }
//            }catch let error {
//                print(error)
//            }
//            print(response.data)
//            print(response.data.description)
//            if response.error != nil {
//                print(response.error)
//            }
//            //do things...
//
//        }
    }
    // image picker did finish
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      //  uploadImageProfile(info)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        
        // We use document directory to place our cloned image
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        
        // Set static name, so everytime image is cloned, it will be named "temp", thus rewrite the last "temp" image.
        // *Don't worry it won't be shown in Photos app.
        let imageName = "temp.png"
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        print("IMAGEPATHOSH: " + imagePath)
        self.profileImageView.layer.borderWidth = 0
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.image = image
        dismiss(animated: true, completion: nil)
        let imageData = UIImagePNGRepresentation(image)!
        print("AlamoUpload: START")
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
       ARSLineProgress.show()
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "single_image",fileName: "profile_image.jpg", mimeType: "image/jpg")
        },to:"https://api.snapgroup.co.il/api/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/profile")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    ARSLineProgress.hide()
                    if let object = response.result.value as? Dictionary<String,AnyObject>{
                        if let imageobj = object["image"] as? Dictionary<String,Any>{


                            if let path = imageobj["path"] as? String{
                                print("DICTIONARY: LEVEL 2")
                                do{
                                    DispatchQueue.global().async(execute: {

                                  DispatchQueue.main.sync {
                                        self.profileImageView.layer.borderWidth = 0
                                        self.profileImageView.layer.masksToBounds = false
                                        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
                                        self.profileImageView.clipsToBounds = true
                                        let urlString =  ApiRouts.Web + path
                                        var url = URL(string: urlString)
                                        self.profileImageView.sd_setImage(with: url!, completed: nil)
                                        self.setToUserDefaults(value: path, key: "profile_image")
                                    }
                                })
                                }
                                catch {
                                    
                                }
                            }
                            
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
     
    }
   
    
//    @IBAction func memberMenuTapped(_ sender: Any) {
//        if isMemberMenuShowing {
//             menuButton.image = UIImage(named: menuIcon)
//            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//            memberLeadingConstraints.constant = 190
//            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//        } else {
//            if isFilterShowing {
//                leadingConstraint.constant = -199
//                isFilterShowing = !isFilterShowing
//                 UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//            }
//
//            menuButton.image = UIImage(named: "arrow right")
//            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//            memberLeadingConstraints.constant = 0
//            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//        }
//
//        isMemberMenuShowing = !isMemberMenuShowing
//    }
//
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.flagImageView.image = flag
        self.countryPrefLable.text = phoneCode
        
    }
   
    
    
    func checkCurrentUser(){
        print("im in check current user Func")
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let isLogged = defaults.bool(forKey: "isLogged")
        let phone = defaults.string(forKey: "phone")
        print("Im in  isLogged \(isLogged)")
        if isLogged == true{

            print("IS logged = true")
            self.getMember(memberId: id)
            setBadges()
                self.isLogged = true
                self.noGroupsView.isHidden = true
                self.id = id
                self.registerView.isHidden = true
                self.phoneNumberStackView.isHidden = true
                self.chatHeaderStackView.isHidden = false
                self.profileImageView.layer.borderWidth = 0
                self.profileImageView.layer.masksToBounds = false
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
                self.profileImageView.clipsToBounds = true

            
            
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
            self.sort = standart_sort
            self.hasLoadMore = true
            print("Phoien is \(phone)")
            if phone != nil && phone! != "no value" {
            self.getGroupsByFilter()
                 myGroupByPhoneView.isHidden = true
            }else {
                myGroupByPhoneView.isHidden = false
                
            }
            
            
            
            
        }else{
            self.page = 1
            self.myGrous = []
            self.hasLoadMore = true
            print("Refresh groups without filter")
            self.phoneNumberFeild.text = ""
            self.phoneNumberStackView.isHidden = false
            self.registerView.isHidden = false
            self.chatHeaderStackView.isHidden = true
            self.isLogged = false
            self.myGroupByPhoneView.isHidden = true

             print("IS logged = false")
          self.getSwiftGroups()
            
        }
       

    //    let prfoile = MemberProfile(member_id: id)
        
        
    }
    //badges counter
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
        self.countryCodeVeiw.isHidden = false
    }
    
    @IBAction func closeCountryViewTapped(_ sender: Any) {
        self.countryCodeVeiw.isHidden = true
    }
    
   
    
    
    func setCountryPicker(){
       
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            countryPicker.setLocale(countryCode)
        }
          countryPicker.setCountry(Locale.current.regionCode!)
    }
    
    
    func checkIfMember(textFeild: String,type: String, facebookMember: FacebookMember?) {
        var params: [String : Any] = ["" : ""]
        let strMethod = String(format : ApiRouts.Web + "/api/check_if_member" )
        if type == "phone"{
            params = ["phone": textFeild]
            
        }
        else
        {
            params = ["facebook_id": textFeild]
            
        }
        print(params)
        let url = URL(string: strMethod)!
        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        if let json = json {  print(json) }
        
        let jsonData = json!.data(using: String.Encoding.utf8.rawValue);
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        var isMmebr: Bool = false
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON {  (response) in
            switch response.result {
            case .success(let JSON2):
                print("Success with JSON: \(JSON2)")
                print("RESPONSE \(response.result)")
                
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                break
            }
            }
            .responseString { response in
               print("is exist ? \(response.result.value!)")
                if (response.result.value!.range(of: "true") != nil)
                {
                    print("Im here in exist")
                    if type == "phone"{
                        
                        self.showPinDialog(phone: textFeild)
                    }
                    else
                    {
                        print("Im here in facebook exist")

                         self.isFacebookGdpr = false
                        self.regstirFacebook(facebookMember: self.facebookMember!, isGdpr:  self.isFacebookGdpr)
                    }
                    
                    
                }else {
                    print("Im here in  else exist")

                    MyVriables.fromGroup = "false"
                    if type != "phone"{
                        MyVriables.facebookMember = facebookMember
                    }else {
                        self.dismiss(animated: true,completion: nil)
                        MyVriables.phoneNumber = textFeild
                    }
                    self.performSegue(withIdentifier: "showGdbr", sender: self)
                }
                
        }
 
    }

    func isValidPhone(phone: String) -> Bool {
    let phoneNumberKit = PhoneNumberKit()
        do {
            print("phone number   \(phone)")
        
            let phoneNumber = try phoneNumberKit.parse(phone)
            print("phone number before parsing \(phoneNumber)")
            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(phone, withRegion: contryCode, ignoreType: true)
            print("phone number after parsing \(phoneNumberCustomDefaultRegion)")
            return true
            }
            catch {
            
            let snackbar = TTGSnackbar(message: "Phone Number is eror please enter a valditae phone number ", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
            print("Generic parser error")
            return false
            }
            print("Phone is \(phone)")
        
            return false
    }
    @IBAction func sendClick(_ sender: Any) {
        
        
        /// check if member
     
        
        if isValidPhone(phone: contryCodeString+phoneNumberFeild.text!)
        {
      
            print("\(self.contryCodeString)\(self.phoneNumberFeild.text!)")
        self.phoneNumber = contryCodeString+phoneNumberFeild.text!
            if self.contryCodeString == "+972" {
                if self.phoneNumberFeild.text!.count > 4 && self.phoneNumberFeild.text![0...0] == "0" {
                    self.phoneNumberFeild.text!.remove(at: self.phoneNumberFeild.text!.startIndex)
                    self.phoneNumber = "\(self.contryCodeString)\(self.phoneNumberFeild.text!)"
                    print("yes im inside \(self.phoneNumber)")
                    
                    
                }
            }
        let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(phoneNumber!)", preferredStyle: .alert)
      
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            let params = ["phone": self.phoneNumber]
            
            HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
                if response.error != nil {
                    print("error \(response.error?.localizedDescription)")
                    return
                }
                print ("successed")
                DispatchQueue.main.sync {
//
                    self.checkIfMember(textFeild: "\(self.contryCodeString)\(self.phoneNumberFeild.text!)",type: "phone", facebookMember: self.facebookMember)
                    
                    
                }
                //do things...
            }
            
          
            
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")

            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
        }
    }
    
    
    public func regstirFacebook(facebookMember : FacebookMember,isGdpr: Bool)
    {
        print("Is gdpr equal to \(isGdpr)")
        var params: [String: Any] = [:]
        if facebookMember.facebook_id != "" {
            if  isGdpr == true
            {
                let gdprArr: [String: Bool] = ["chat_messaging":(MyVriables.arrayGdpr?.chat_messaging)!,
                                               "files_upload":(MyVriables.arrayGdpr?.files_upload)!,
                                               "groups_relations":(MyVriables.arrayGdpr?.groups_relations)!,
                                               "pairing":(MyVriables.arrayGdpr?.pairing)!,
                                               "phone_number":(MyVriables.arrayGdpr?.phone_number)!,
                                               "profile_details":(MyVriables.arrayGdpr?.profile_details)!,
                                               "push_notifications":(MyVriables.arrayGdpr?.push_notifications)!,
                                               "real_time_location":(MyVriables.arrayGdpr?.real_time_location)!,
                                               "rating_reviews":(MyVriables.arrayGdpr?.rating_reviews)!]
                print("GDPRARR from faceboooook - \(gdprArr)")
                params = ["facebook_id": facebookMember.facebook_id!, "type": "facebook", "first_name": facebookMember.first_name!,"last_name": facebookMember.last_name!,"facebook_profile_image": facebookMember.facebook_profile_image != nil ? facebookMember.facebook_profile_image! : nil, "gdpr":gdprArr]
            }
            else{
               params = ["facebook_id": facebookMember.facebook_id!, "type": "facebook", "first_name": facebookMember.first_name!,"last_name": facebookMember.last_name!,"facebook_profile_image": facebookMember.facebook_profile_image != nil ? facebookMember.facebook_profile_image! : nil]
            }
            
        print("Regstir Faceook id is \(facebookMember)")
        HTTP.POST(ApiRouts.Register, parameters: params) { response in
            //do things...
            if response.error != nil {
                print("im in error func \(response.error)")
                return
            }
            print("im in response func \(response.description)")
            do{
                let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                self.currentMember = member
                self.setToUserDefaults(value: true, key: "isLogged")
                self.setToUserDefaults(value: self.currentMember?.profile?.member_id!, key: "member_id")
                self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                if self.currentMember?.profile?.profile_image == nil
                {
                       self.setToUserDefaults(value: self.currentMember?.profile?.facebook_profile_image, key: "profile_image")
                }
                else{
                self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                }
                self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")

                self.currentProfile = self.currentMember?.profile!
                DispatchQueue.main.sync {
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.profile?.member_id!)!))")

                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.profile?.member_id!)!))")

                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                    }
                    self.myGrous = []
                    self.page = 1
                    self.tableView.reloadData()
                    self.checkCurrentUser()

                }
                MyVriables.isMember = true


            }
            catch {
                print("catch error")
                self.phoneNumberStackView.isHidden = false
                self.registerView.isHidden = false
                self.chatHeaderStackView.isHidden = true
                self.setToUserDefaults(value: false, key: "isLogged")

            }
            
            
        }
        }else {
            
        }
    }
    public func showPinDialog(phone: String) {
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created")
        
        PinAlert.addTextField { (textField) in
            textField.placeholder = "1234"
            //textField.shouldChangeText(in: 6, replacementText: "")
            
        }
        print ("pin created")
        
        PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
            
            print ("pin 1")
            
            let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
            print ("pin 2")
            
            self.PINCODE = textField?.text
            print("PIN CODE : \((textField?.text)!)")
            var params: [String: Any] = [:]
            params = ["code": (textField?.text)!, "phone": phone]
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
                     self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                    self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                     self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                   
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                             Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                        }
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
                    self.registerView.isHidden = false
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
        ARSLineProgress.show()
        print("request PAGE = \(self.page)")
        print("Im in all groups sort url ==" + ApiRouts.AllGroupsRequest +  "?page=\(self.page)&sort=created_at&order=des")
        var groups: [TourGroup]?
        HTTP.GET(ApiRouts.Web + "/api/groups?page=\(self.page)&sort=created_at&order=des") { response in
            print(ApiRouts.AllGroupsRequest)
            //do things...
          //  print(response.description)
            let data = response.data
//            print(response)

            do {
                let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                groups = groups2.data!
                ARSLineProgress.hide()
                if (groups2.total)! == 0
                {
                    DispatchQueue.main.async {
                        self.hasLoadMore = false
                        self.noGroupsView.isHidden = false
                    }
                    return
                }else
                {
                    DispatchQueue.main.async {
                        self.noGroupsView.isHidden = true
                    }
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
                DispatchQueue.main.sync {
                    if self.page > groups2.last_page!
                    {
                        self.hasLoadMore = false
                        self.refresher.endRefreshing()
                        
                        return
                    }
                    self.isLoading = false

                }
                
                
               

              //  print(self.myGrous.count)
            }
            catch {
                
            }
            
        }
    }
    
    fileprivate func getAllGroup() {
        self.filter = "all"
        self.myGrous = []
        self.page = 1
        self.hasLoadMore = true
        self.getGroupsByFilter()
    }
    
    func getGroupsByFilter() {
        print("request PAGE = \(self.page)")


        let defaults = UserDefaults.standard
        let phone = defaults.string(forKey: "phone")
        self.myGroupByPhoneView.isHidden = true

        var groups: [TourGroup]?
        let withoutFilter = "/api/groups/members/\(self.id)?page=\(self.page)&sort=\(self.sort)"
       // let withoutFilter = "/api/groups?page=\(self.page)&sort=\(self.sort)"
        let withRole = "/api/groups/members/\(self.id)?page=\(self.page)&role=group_leader&sort=\(self.sort)"
        let withFilter = "/api/groups?member_id=\(self.id)&page=\(self.page)&filter=\(self.filter)&sort=\(self.sort)"
        let allGroupsFilter = "/api/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)"
        let searchUrl  = "/api/groups?member_id=\(self.id)?page=\(self.page)&sort=\(self.sort)&search=\(self.search)"
            ////url = Constants.SERVERIP + "api/groups?member_id="+userId+"&search=" + arrayForFilter[2]
           // +"&page="+page+"&sort=created_at&order=desc";
        var lastFilter: String
        if filter == "all" {
            print("Im here in filter == all")
            lastFilter = allGroupsFilter
        }
        else if filter == "search" {
            noGroupText.text = " We could not find groups using the search words you provided. Please try again later."
            lastFilter = searchUrl
        }
        else if filter == "leader" {
             noGroupText.text = " You currently do not have any groups that you create or mange."
            lastFilter = withRole
        }
        else if filter == "no-filter" {
            print("Im here in filter == no-filter")
            let defaults = UserDefaults.standard
            let phone = defaults.string(forKey: "phone")
            ARSLineProgress.hide()
            if phone != nil && phone! != "no value" {
                myGroupByPhoneView.isHidden = true
            }else {
                myGroupByPhoneView.isHidden = false
                return
                
            }
            
            lastFilter = withoutFilter
        }else{
            lastFilter = withFilter
        }
        print("The url is \(ApiRouts.Web+lastFilter)")
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

                if (groups2.total)! == 0
                {
                    if self.filter == "no-filter" {
                        DispatchQueue.main.async {
                             self.noGroupsView.isHidden = true
                            let snackbar = TTGSnackbar(message: "You currently have no groups related to you. Check our public groups", duration: .middle)
                            snackbar.icon = UIImage(named: "AppIcon")
                            snackbar.show()
                            self.hasLoadMore = false
                            self.getAllGroup()
                           
                            
                            
                        }
                       
                    }else {
                    DispatchQueue.main.async {
                        self.noGroupsView.isHidden = false
                    }
                    }
                }else
                {
                    DispatchQueue.main.async {
                        self.noGroupsView.isHidden = true
                    }
                }
                // self.noGroupsView.isHidden = true
                
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
                    self.isLoading = false
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
    

    func getMember(memberId: Int){
        
        print("Im in get Member")
        print("Url is " + ApiRouts.Web +  "/api/members/member/\(memberId)")
        HTTP.GET(ApiRouts.Web +  "/api/members/member/\(memberId)", parameters: []) { response in
            //do things...
            if response.error != nil {
                print(response.error)
                return
            }
            print(response.description)
            do{
                let  member : MyMemberInfo = try JSONDecoder().decode(MyMemberInfo.self, from: response.data)
                if response.error != nil {
                    print("Memberinfo is \(response.error)")
                }else {
                    print("MemberInfo is" + "*************")
                    print(member.member?.gdpr)
                    print("*************")

                }
                
                self.currentMember = CurrentMember(member: member.member, profile: member.member?.profile, total_unread_messages: (member.total_unread_messages)!, total_unread_notifications: (member.total_unread_notifications)!)
                MyVriables.currentMember =  (self.currentMember?.member)!
                MyVriables.currentMember?.gdpr = member.member?.gdpr!
                print("All profile  is \((MyVriables.currentMember)!)")
                MyVriables.currentMember?.id = (member.member?.profile?.member_id)!
                print("Member id is \(MyVriables.currentMember?.id!)")
                print("Struct Gdpr : \((MyVriables.currentMember)!)")
                
                /*
 (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false
                */
                DispatchQueue.main.async {
                    if (MyVriables.currentMember?.gdpr?.push_notifications) != nil
                    {
                        if (MyVriables.currentMember?.gdpr?.push_notifications)! == false
                        {
                            self.notficicationIcon.image = UIImage(named: "pushNotiOff")
                            self.notficationLbl.alpha = 0.3
                            
                            UIApplication.shared.unregisterForRemoteNotifications()
                        }
                        else
                        {
                            self.notficicationIcon.image = UIImage(named: "pushNotiOn")
                            self.notficationLbl.alpha = 1
                            SwiftEventBus.post("shouldRefreshGdpr")
                            
                        }
                        
                    }
                }
               
                self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                self.setToUserDefaults(value: (self.currentMember?.member?.profile_image) != nil ? (self.currentMember?.member?.profile_image)! : nil, key: "profile_image")
                self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                //print("Current profile image is \(self.currentMember?.profile?.profile_image != nil ? (self.currentMember?.profile?.profile_image)! : "")")

                do {
                    try DispatchQueue.main.sync {
                    let defaults = UserDefaults.standard
                    let first = defaults.string(forKey: "first_name")
                    let last = defaults.string(forKey: "last_name")
                    let gender = defaults.string(forKey: "gender")
                    let phone = defaults.string(forKey: "phone")
                    let id = defaults.integer(forKey: "member_id")
                    let profile_image = defaults.string(forKey: "profile_image")
                    let chat_counter = defaults.integer(forKey: "chat_counter")
                    let inbox_counter = defaults.integer(forKey: "inbox_counter")
                        
                    print("notfaction is \(inbox_counter) and chats is \(chat_counter)")
                    if let profile =  member.member?.profile {
                        print("PROFILE: OK")
                        
                        self.currentProfile = member.member?.profile
                    }else {
                        print("PROFILE: NULL")
                    }
                    if first != nil && last != nil {
                        if first == "no value" || last == "no value" {
                            var z = 1500 + id
                            self.memberNameLbl.text = "Guest\(z)"
                        }
                        else {
                           self.memberNameLbl.text = (first)! + " " + (last)!
                        }
                        
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
                    
                    //urstri
                    if profile_image != nil {
                        if profile_image == "no value"
                        {
                            self.profileImageView.image = UIImage(named : "default user")
                        }
                        else {
                            var urlString : String?
                            if (profile_image?.contains("http"))!
                            {
                                urlString = (profile_image)!
                            }else{
                         urlString = ApiRouts.Web + (profile_image)!
                            }
                        print("Url string is \(urlString)")
                            urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                            var url = URL(string: urlString!)
                        if url != nil {
                            self.profileImageView.sd_setImage(with: url!, completed: nil)
                        }
                        }
                        
                    }
                     //SwiftEventBus.post("counters")
                    
                }
                }catch {
                    
                }
                
            }
            catch {
                
                
            }
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if let destination = segue.destination as? GroupViewController {
//            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
//        }
//        
//        if let destination = segue.destination as? HomeViewController {
//            print("home destination")
//            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
//        }
    }


    
    /////////////////////////////// Tableview initialize ///////////////////////////
    
    
    // pagination loadmore : check last item
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastitem =  self.myGrous.count
        let currentIndex : Int = indexPath.row + 1
     
        if currentIndex == lastitem && hasLoadMore == true && !self.isLoading{
               print("Last item is \(lastitem) and index is \(indexPath.row)")
            self.isLoading = true

            print("Reach last")

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
        if currentIndex > -1 && currentIndex < self.myGrous.count {
        if self.myGrous[currentIndex].image != nil{
            do{
                var urlString: String = try ApiRouts.Web + (self.myGrous[currentIndex].image)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
//                     cell.imageosh.sd_setImage(with: url, placeholderImage: UIImage(named: "Group Placeholder"), completed: nil)
                     cell.imageosh.kf.indicatorType = .activity
                    cell.imageosh.kf.setImage(with: url)
                    
                    

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
            
            cell.groupLeaderLbl.text = (self.myGrous[currentIndex].group_leader_first_name != nil ? self.myGrous[currentIndex].group_leader_first_name! : "" ) + " " + (self.myGrous[currentIndex].group_leader_last_name != nil ? self.myGrous[currentIndex].group_leader_last_name! : "" )
            
            if self.myGrous[currentIndex].group_leader_image != nil{
                do{
                    
                    var urlString = try ApiRouts.Web + (self.myGrous[currentIndex].group_leader_image)!
                    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    
                    var url = URL(string: urlString)
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.kf.setImage(with: url!)
                        cell.groupLeaderImageView.layer.cornerRadius = cell.groupLeaderImageView.frame.size.width / 2;
                        cell.groupLeaderImageView.clipsToBounds = true;
                        cell.groupLeaderImageView.layer.borderWidth = 1.0
                        cell.groupLeaderImageView.layer.borderColor = UIColor.gray.cgColor
                        cell.groupLeaderImageView.contentMode = .scaleAspectFill
                    }
                }
                catch let error{
                }
                
            }
            else
            {
                cell.groupLeaderImageView.image = UIImage(named: "default user")
                cell.groupLeaderImageView.layer.borderWidth = 0
                cell.groupLeaderImageView.layer.cornerRadius = 0;
                cell.groupLeaderImageView.clipsToBounds = false;
            }
           
        } // if just group leader
        else{
            cell.groupLeaderLbl.text = self.myGrous[currentIndex].group_leader_company_name != nil ? self.myGrous[currentIndex].group_leader_company_name! : "Company"
            if self.myGrous[currentIndex].group_leader_company_image != nil{
                
                do{
                    var urlString = try ApiRouts.Web + (self.myGrous[currentIndex].group_leader_company_image)!
                    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    var url = URL(string: urlString)
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.kf.setImage(with: url!)
                        
                    }
                }catch {
                    
                }
            }
            else
            {
                cell.groupLeaderImageView.image = UIImage(named: "group tools title")
            }
            cell.groupLeaderImageView.layer.borderWidth = 0
            cell.groupLeaderImageView.layer.cornerRadius = 0;
            cell.groupLeaderImageView.clipsToBounds = false;
            cell.groupLeaderImageView.contentMode = .scaleAspectFit
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatter.date(from: date)!
        var days = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day! as? Int
        var hours = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour! as? Int
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
               // UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
                self.isFilterShowing = !self.isFilterShowing
            }
       else  if isMemberMenuShowing {
            menuImage.image = UIImage(named: menuIcon)
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
                    let params: [String: Any] = ["member_id": (MyVriables.currentMember?.id!)! , "group_id": (MyVriables.currentGroup?.id!)! , "type": ApiRouts.VisitGroupType]
                    print("PARAMS - \(params)")
                    ApiRouts.actionRequest(parameters: params)
                    
                    
                    
                }else {
                    showCloseAlert()
                }
            }else{
                MyVriables.currentGroup = self.myGrous[currentIndex]
                self.performSegue(withIdentifier: "groupDetailsBar", sender: self)
                let params: [String: Any] = ["member_id": (MyVriables.currentMember?.id!)! , "group_id": (MyVriables.currentGroup?.id!)! , "type": ApiRouts.VisitGroupType]
                print(params)
                print("PARAMS - \(params)")
                ApiRouts.actionRequest(parameters: params)

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
       
        self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
        self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
        self.closeFilterSlide()
         search = ""
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
    public func showPinDialogGdpr() {
        // dismiss(animated: true, completion: nil)
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created")
        
        PinAlert.addTextField { (textField) in
            textField.placeholder = "1234"
            //textField.shouldChangeText(in: 6, replacementText: "")
        }
        print ("pin created")
        
        PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
            
            print ("pin 1")
            
            let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
            print ("pin 2")
            
            self.PINCODE = textField?.text
            print("PIN CODE : \((textField?.text)!)")
            let gdprArr: [String: Bool] = ["chat_messaging":(MyVriables.arrayGdpr?.chat_messaging)!,
                                         "files_upload":(MyVriables.arrayGdpr?.files_upload)!,
                                         "groups_relations":(MyVriables.arrayGdpr?.groups_relations)!,
                                         "pairing":(MyVriables.arrayGdpr?.pairing)!,
                                         "phone_number":(MyVriables.arrayGdpr?.phone_number)!,
                                         "profile_details":(MyVriables.arrayGdpr?.profile_details)!,
                                         "push_notifications":(MyVriables.arrayGdpr?.push_notifications)!,
                                         "real_time_location":(MyVriables.arrayGdpr?.real_time_location)!,
                                         "rating_reviews":(MyVriables.arrayGdpr?.rating_reviews)!]
            print("GDPRARR- \(gdprArr)")
            let params: [String: Any]
            params = ["code": (textField?.text)!, "phone": MyVriables.phoneNumber!, "gdpr":gdprArr
            ]
            print("Parmas is \(params)")
            print("GDPR = \(MyVriables.arrayGdpr!)")
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
                     self.setToUserDefaults(value: self.currentMember?.profile?.member_id!, key: "gdprNotfication")
                    self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                    self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                    self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                    self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                    self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                    self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                    self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                    
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                       
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember? .profile?.member_id!)!))")
                        }
                        self.myGrous = []
                        self.page = 1
                        self.tableView.reloadData()
                        self.checkCurrentUser()
                        //                                    self.phoneNumberStackView.isHidden = true
                        //                                    self.chatHeaderStackView.isHidden = false
                        //
                        
                    }
                    
                    MyVriables.isMember = true
                    
                    
                }
                catch {
                    self.registerView.isHidden = false
                    self.phoneNumberStackView.isHidden = false
                    self.chatHeaderStackView.isHidden = true
                    self.setToUserDefaults(value: false, key: "isLogged")
                    print("catch error")

                    
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
    
    func refreshDataFromGdbr() {
        self.myGrous = []
        self.page = 1
        self.tableView.reloadData()
        self.checkCurrentUser()
    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        contryCodeString = country.phoneCode
        contryCode = country.code
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
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 6 //
    }
}
