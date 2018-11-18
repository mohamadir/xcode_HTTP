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
import FBSDKLoginKit
import FBSDKCoreKit
import FTPopOverMenu_Swift
import PopoverSwift
import BetterSegmentedControl
import GooglePlacesSearchController
import JGProgressHUD
import AAMultiSelectController
import SwiftCheckboxDialog
import CheckboxList
import SwiftyPickerPopover
import TTRangeSlider
import UIScrollView_InfiniteScroll

//import FTPopOverMenu_Swift



/***********************************************      VIEW CONTROLLER     *************************************************************/


class ViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource ,  MRCountryPickerDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate,UICollectionViewDelegateFlowLayout,GooglePlacesAutocompleteViewControllerDelegate, CheckboxDialogViewDelegate,UIPickerViewDelegate, UIScrollViewDelegate {

    func onCheckboxPickerValueChange(_ component: DialogCheckboxViewEnum, values: TranslationDictionary) {
        print(component)
        print(values)
    }
    
    func viewController(didAutocompleteWith place: PlaceDetails) {
        print(place.description)
        placesSearchController.isActive = false
        searchDestantion.text = "\((place.name != nil ? place.name : "" )!) ,  \((place.country != nil ? place.country : "" )!)"
        
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    @IBOutlet weak var pricessRange: TTRangeSlider!
    @IBOutlet weak var rangeDays: TTRangeSlider!
    var filterUrl: String = ""
    var groupIndex: Int = 0
    var groupBothIndex: Int = 0
    var grroupsType: [String] = ["Unique Groups", "Both",  "Reccuring Groups"]
    var groupsTypeAfterReg: [String] = ["All Groups", "My Groups", "Specials", "Groups I Own"]
    var groupsTypeBeforeReg: [String] = ["All Groups", "Specials"]
    var menuOptionNameArray = ["All groups", "My groups", "One day groups","Multi days groups"]
    var minimumDate : Date?
    var maximumDate : Date?
    var dateString: String?
    @IBAction func start_date(_ sender: Any) {
        /// Create StringPickerPopover:
        let p = DatePickerPopover(title: "Birth Date")
        p.setDateMode(.date)
        let currentDate: Date = Date()
        
//        p.setMaximumDate(self.maximumDate!)
//        p.setMinimumDate(self.minimumDate!)
        p.setSelectedDate(Date())
        p.setDoneButton(color: Colors.PrimaryColor, action: { popover, selectedDate in print("selectedDate \(selectedDate + 1)")
            
            self.dateString = selectedDate.description
            let myString: String = self.dateString!;
            var myStringArr = myString.components(separatedBy: " ")

            if (self.endDateLbl.titleLabel?.text)! != "Set Date" {
                if (self.checkTimeStamp(end_date:(self.endDateLbl.titleLabel?.text)!, start_date: self.setDate(mydateis: myStringArr [0]), isBig: true)) {
                    self.startDateLbl.setTitle(self.setDate(mydateis: myStringArr [0]), for: .normal)

                }else {
                    let snackbar = TTGSnackbar(message: "Start date must be less than end date.", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
            }else{
                self.startDateLbl.setTitle(self.setDate(mydateis: myStringArr [0]), for: .normal)

            }
            
        })
        
        p.setCancelButton(color: Colors.PrimaryColor, action: { _, _ in
            print("cancel")})
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    @IBOutlet weak var radiosLbl: UITextField!
    @IBAction func resetFilter(_ sender: Any) {
        self.rangeDays.selectedMaximum = 100.0
        self.rangeDays.selectedMinimum = 1.0
        self.pricessRange.selectedMaximum = 5000.0
        self.pricessRange.selectedMinimum = 0.0
        radiosLbl.text = ""
        searchDestantion.text = ""
        self.endDateLbl.setTitle("Set Date", for: .normal)
        self.startDateLbl.setTitle("Set Date", for: .normal)
        catgoreyLbl.text = "Categories.."
        companyLbl.text = "Companies.."
        self.filterCatgory = []
        self.filterCompany = []
    }
    fileprivate func setFilterUrl() {
        if isLogged {
            switch self.groupsTypeAfterReg[groupIndex] {
            case "All Groups":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)"
            case "My Groups":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&my_groups=true&page=\(self.page)&sort=\(self.sort)"
            case "Specials":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)&special_price=true"
            case "Groups I Own":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&my_groups=true&page=\(self.page)&sort=\(self.sort)&roles[]=group_leader"
            default:
                print("")
            }
            
        }
        else {
            switch self.groupsTypeBeforeReg[groupIndex] {
            case "All Groups":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?page=\(self.page)&sort=created_at&order=des"
            case "Specials":
                self.filterUrl = ApiRouts.ApiV3 + "/groups?page=\(self.page)&sort=created_at&order=des&special_price=true"
            default:
                print("")
            }
            
        }
        switch self.grroupsType[self.groupBothIndex] {
        case "Unique Groups":
            self.filterUrl = self.filterUrl + "&rotation=one_time"
        case "Reccuring Groups":
            self.filterUrl = self.filterUrl + "&rotation=reccuring"
        default:
            print("")
        }
        self.filterUrl = self.filterUrl + "&min_days=\((Int((self.rangeDays.selectedMinimum).rounded())))&max_days=\((Int((self.rangeDays.selectedMaximum).rounded())))" + "&min_price=\((Int((self.pricessRange.selectedMinimum).rounded())))&max_price=\((Int((self.pricessRange.selectedMaximum).rounded())))"
        if searchDestantion.text != nil && (searchDestantion.text)! != "" {
            if radiosLbl.text != nil && (radiosLbl.text)! != "" {
                self.filterUrl = self.filterUrl + "&destination=\((searchDestantion.text)!)&radius=\((radiosLbl.text)!)"
            }else {
                self.filterUrl = self.filterUrl + "&destination=\((searchDestantion.text)!)"
            }
        }
        if (startDateLbl.titleLabel?.text)! != "Set Date" {
            self.filterUrl = self.filterUrl + "&start_date=\((startDateLbl.titleLabel?.text)!)"
        }
        if (endDateLbl.titleLabel?.text)! != "Set Date" {
            self.filterUrl = self.filterUrl + "&end_date=\((endDateLbl.titleLabel?.text)!)"
        }
        if (catgoreyLbl.text)! != "Categories.." {
            self.filterUrl = self.filterUrl + "&\(catgoryString)"
        }
        if (companyLbl.text)! != "Companies.." {
            self.filterUrl = self.filterUrl + "&\(companiesString)"
        }
    }
    
    fileprivate func hideFilter() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            
            self.scrollFilter.slideInFromLeft(type: "top")
        }) { (success) in
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.scrollFilter.isHidden = true
            }, completion: nil)
        }
    }
    
    @IBAction func updateFilter(_ sender: Any) {
        self.page = 1
        setFilterUrl()

      //  print("The url is page \(self.page)")
        self.lastitem = 0
        self.myGrous = []
        self.hasLoadMore = true
        self.filter = "filter"
        self.tableView.reloadData()
        
        //print("The url is page \(self.page)")
        self.getGroupsByFilter()
        
        hideFilter()
        // self.scrollFilter.isHidden = true
        
        
        
    }
    @IBAction func end_date(_ sender: Any) {
        /// Create StringPickerPopover:
        let p = DatePickerPopover(title: "Birth Date")
        p.setDateMode(.date)
        let currentDate: Date = Date()
        
//        p.setMaximumDate(self.maximumDate!)
//        p.setMinimumDate(self.minimumDate!)
        p.setSelectedDate(Date())
        p.setDoneButton(color: Colors.PrimaryColor, action: { popover, selectedDate in print("selectedDate \(selectedDate + 1)")
            
            self.dateString = selectedDate.description
            var myString: String = self.dateString!;
            var myStringArr = myString.components(separatedBy: " ")
            if (self.startDateLbl.titleLabel?.text)! != "Set Date" {
                if (self.checkTimeStamp(end_date: self.setDate(mydateis: myStringArr [0]), start_date: (self.startDateLbl.titleLabel?.text)!, isBig: true)) {
                    self.endDateLbl.setTitle(self.setDate(mydateis: myStringArr [0]), for: .normal)
                }else {
                    let snackbar = TTGSnackbar(message: "End date must be greater than start date.", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
            }else{
                
                self.endDateLbl.setTitle(self.setDate(mydateis: myStringArr [0]), for: .normal)
            }
        })
        
        p.setCancelButton(color: Colors.PrimaryColor, action: { _, _ in
            print("cancel")})
        p.appear(originView: sender as! UIView, baseViewController: self)
    }
    func checkTimeStamp(end_date: String!, start_date: String!, isBig: Bool) -> Bool {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let datecomponents = dateFormatter.date(from: end_date)
        
        let dateFormatter2: DateFormatter = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        let datecomponents2 = dateFormatter2.date(from: start_date)

        if isBig {
        if (datecomponents! > datecomponents2!) || (datecomponents! == datecomponents2!) {
            return true
        } else {
            return false
        }
        } else{
            if (datecomponents! > datecomponents2!) || (datecomponents! == datecomponents2!) {
                return true
            } else {
                return false
            }
        }
    }
    @IBOutlet weak var endDateLbl: UIButton!
    @IBOutlet weak var startDateLbl: UIButton!
    @IBOutlet weak var scrollFilter: UIScrollView!
    @IBOutlet weak var frequncyTabs: BetterSegmentedControl!
    @IBOutlet weak var gridImage: UIImageView!
    @IBOutlet weak var instgramImage: UIImageView!
    @IBOutlet weak var lisviewImage: UIImageView!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var filtersBtton: BetterSegmentedControl!
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    var menuOptionImageNameArray = ["", "", "",""]
    @IBOutlet var pickerFacebookView: UIView!
    // header views
    var clickes: [Bool] =  [true,false,false,false]
    var contryCodeString : String = ""
    var contryCode : String = ""
    @IBOutlet var menuView: UIView!
    @IBOutlet weak var phoneFacebookLbl: UITextField!
    @IBOutlet weak var searchBarFilter: UISearchBar!
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
    @IBOutlet weak var searchbarButrnsView: UIView!
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var countyCodePickerView: CountryPickerView!
    var typeCell: String = "instaView"
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
    @IBOutlet weak var helpViews: UIView!
    @IBOutlet var memberMenuView: UIView!
    @IBOutlet var memberNameLbl: UILabel!
    @IBOutlet var memberPhoneLbl: UILabel!
    @IBOutlet var memberGenderLbl: UILabel!
    @IBOutlet var notificationsImageView: UIImageView!
    @IBOutlet var noGroupsView: UIView!
    @IBOutlet var InboxCounterView: DesignableView!
    @IBOutlet var ChatCounterView: DesignableView!
    @IBOutlet var countryCodeVeiw: UIView!
    var phonenumber_ : String = ""
    @IBOutlet var myGroupByPhoneView: UIView!
    @IBOutlet var chatView: UIView!
    @IBOutlet var inboxView: UIView!
    @IBOutlet var inboxCounterLbl: UILabel!
    @IBOutlet var chatCounterLbl: UILabel!
    var lastitem : Int = 0
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
    
    @IBOutlet weak var tourSupplierViewSelect: UIView!
    @IBOutlet weak var categoryViewSelect: UIView!
    @IBOutlet weak var clearTextFild: UIView!
    let hud = JGProgressHUD(style: .dark)
   
     /****** Filter  ************/
    
    
    
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
    func setDate(mydateis : String) -> String {
        var cerntdate = mydateis.components(separatedBy: "-")
        let year:Int? = Int(cerntdate[0])
        let mounth:Int? = Int(cerntdate[1])
        let day:Int? = Int(cerntdate[2])
        let calendar = Calendar.current
        
        var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
        dateComponents?.day = day!
        dateComponents?.month = mounth!
        dateComponents?.year = year!
        let date: Date? = calendar.date(from: dateComponents!)
        let tomorrow = date?.add(days: 1)
        print("THIUS \(tomorrow!) year \(year!)")
        var finalDate = date?.description.components(separatedBy: " ")
        return finalDate![0]
    }
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = +5
        
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -5
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
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
                        
                        HTTP.PUT(ApiRouts.Api + "/members/\(id)/phone?no_password=true", parameters: ["phone" : self.phoneNumber, "country_code" : self.contryCodeString]) { response in
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
//
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "privacyVc") as! PrivacyViewController
//        self.present(vc, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "privacyVc") as! PrivacyViewController
        self.navigationController?.pushViewController(vc,animated: true)
    }
    @IBAction func closeNewFilter(_ sender: Any) {
        hideFilter()
    }
    @IBOutlet weak var newFilterView: UIView!
    @IBOutlet var settingClick: UIButton!
    /******* VARIABLES *********/
    var menuIcon: String = "menuheader-white"
    var myGrous: [GroupItemObject] = []
    var currentGroup: GroupItemObject?
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
    var filter: String = "all"
    var sort: String = ""
    var isLogged: Bool = false
    var id: Int = -1
    var isMemberMenuShowing: Bool = false
    
    @IBAction func filterClick(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            
            self.scrollFilter.slideInFromLeft(type: "top")
        }) { (success) in
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.scrollFilter.isHidden = false
            }, completion: nil)
        }
        
        
//        print("Im clicked")
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
    }
    @IBAction func onFilterTapped(_ sender: Any) {
        //newFilterView.isHidden = false
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
    @IBOutlet weak var companyLbl: UILabel!
    var  filterCompany : [FilterCompanies]?
    var filterCatgory : [FilterCatgory]?
    @IBOutlet weak var catgoreyLbl: UILabel!
    @IBAction func settingsClick(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: sender)
    }
    var companiesString: String = ""
    var catgoryString: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SwiftEventBus.onMainThread(self, name: "MultiSelect") { result in
            var st: String = ""
            
            if MyVriables.isCatgory{
                self.filterCatgory  = result!.object as? [FilterCatgory]
                self.catgoryString = ""
                if self.filterCatgory != nil && (self.filterCatgory?.count)! > 0 {
                    for filter in self.filterCatgory! {
                        st = st + "\((filter.title)!) , "
                        self.catgoryString = self.catgoryString + "categories[]=\((filter.title)!)&"
                    }
                    self.catgoryString = String(self.catgoryString.dropLast())
                    st = String(st.dropLast())
                    st = String(st.dropLast())
                    self.catgoreyLbl.text = st
                }else {
                    self.catgoreyLbl.text = "Categories.."
                }

            }else {
                self.companiesString = ""
                self.filterCompany = result!.object as? [FilterCompanies]
                if  self.filterCompany != nil &&  (self.filterCompany?.count)! > 0 {
                    for filter in self.filterCompany! {
                        st = st + "\((filter.name)!) , "
                        self.companiesString = self.companiesString + "companies[]=\((filter.name)!)&"
                    }
                    self.companiesString = String(self.companiesString.dropLast())
                    st = String(st.dropLast())
                    st = String(st.dropLast())
                    self.companyLbl.text = st
                }else {
                    self.companyLbl.text = "Companies.."
                }

                
            }
           
        }
        

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
        HTTP.PUT(ApiRouts.Api +  "/members/\((MyVriables.currentMember?.id)!)/gdpr", parameters: params) {
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
        let defaults = UserDefaults.standard
        self.isLogged = defaults.bool(forKey: "isLogged")
        if self.isLogged == true
        {
            self.setBadges()

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
                self.groupCollectionView.reloadData()
                print("Refresh groups without filter")
                self.phoneNumberFeild.text = ""
                self.filterClickView.isHidden = true
                self.filterButton.isHidden = true
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
        if self.memberLeadingConstraints.constant == 0 {
        self.menuImage.image = UIImage(named: self.menuIcon)
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        self.memberLeadingConstraints.constant = 190
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            
            self.scrollFilter.slideInFromLeft(type: "down")
        }) { (success) in
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.scrollFilter.isHidden = false
            }, completion: nil)
        }
       scrollFilter.isHidden = false
//            if isMemberMenuShowing {
//                menuImage.image = UIImage(named: menuIcon)
//                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//                memberLeadingConstraints.constant = 190
//                isMemberMenuShowing = !isMemberMenuShowing
//                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
//            }
//        isFilterShowing = !isFilterShowing
//        var items : [PopoverItem] = []
//        var controller: PopoverController?
//        var item1,item0,item2,item3,item4 : PopoverItem?
//        item0 = PopoverItem(title: "All groups", titleColor: self.clickes[0] == true ? Colors.PrimaryColor : UIColor.black, image : UIImage(named: "")) { debugPrint($0.title)
//            self.clickes[0] = true
//            self.clickes[1] = false
//            self.clickes[2] = false
//            self.clickes[3] = false
//            self.filter = "all"
//            self.sort = "created_at&order=desc"
//            self.refreshData()
//        }
//        item1 = PopoverItem(title: "My groups", titleColor: self.clickes[1] == true ? Colors.PrimaryColor : UIColor.black, image : UIImage(named: "")) { debugPrint($0.title)
//            self.clickes[0] = false
//            self.clickes[2] = false
//            self.clickes[3] = false
//            self.clickes[1] = true
//            self.search = ""
//            self.sort = self.standart_sort
//            self.filter = "no-filter"
//            // showToast("My Message", 3.0)
//            self.refreshData()
//        }
//
//         item3 = PopoverItem(title: "One day groups", titleColor: self.clickes[2] == true ? Colors.PrimaryColor : UIColor.black, image: UIImage(named: "")) { debugPrint($0.titleColor)
//            print("asd")
//            self.clickes[0] = false
//            self.clickes[1] = false
//            self.clickes[3] = false
//            self.clickes[2] = true
//            self.search = ""
//            self.filter = "day"
//            self.sort = "created_at&order=desc"
//            self.refreshData()
//        }
//         item4 = PopoverItem(title: "Multi days groups", titleColor: self.clickes[3] == true ? Colors.PrimaryColor : UIColor.black, image: UIImage(named: "")) { debugPrint($0.title)
//            self.clickes[0] = false
//            self.clickes[1] = false
//            self.clickes[2] = false
//            self.clickes[3] = true
//            self.filter = "days"
//            self.sort = "created_at&order=desc"
//            self.refreshData()
//        }
//
//        print("Im here in filter")
//         items = [item0!, item1!,item3!, item4!]
//        controller = PopoverController(items: items, fromView: filterButton, direction: .down, style: .normal)
//        popover(controller!)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    func dismissKeyboardd() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        self.hud.dismiss()
    }
    lazy var placesSearchController: GooglePlacesSearchController = {
        let controller = GooglePlacesSearchController(delegate: self,
                                                      apiKey: "AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg",
                                                      placeType: .all
            // Optional: coordinate: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
            // Optional: radius: 10,
            // Optional: strictBounds: true,
            // Optional: searchBarPlaceholder: "Start typing..."
        )
        //Optional: controller.searchBar.isTranslucent = false
        //Optional: controller.searchBar.barStyle = .black
        //Optional: controller.searchBar.tintColor = .white
        //Optional: controller.searchBar.barTintColor = .black
        return controller
    }()
     func myTargetFunction() {
        print("im in myTargetFunction")
    present(placesSearchController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var checkList: ChecklistView!
    @IBOutlet weak var filterClickView: UIView!
    @IBOutlet weak var hidePhonePicker: UIView!
    @IBOutlet weak var hideSearchView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var newSearcIcon: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hiosh")
        set18YearValidation()
        clearTextFild.addTapGestureRecognizer {
            self.searchDestantion.text = ""
        }
        tourSupplierViewSelect.addTapGestureRecognizer {
            MyVriables.isCatgory = false
            if self.filterCompany != nil {
                MyVriables.filterComapnies = self.filterCompany
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MultiSelectViewController") as! MultiSelectViewController
            self.present(vc, animated: true, completion: nil)
            // multy
        }
        //tableView.beginInfiniteScroll(true)
        self.groupCollectionView.addInfiniteScroll { (groupCollectionView) -> Void in
            groupCollectionView.performBatchUpdates({ () -> Void in
                if  self.hasLoadMore == true && !self.isLoading{
                    
                    self.isLoading = true
                    
                    print("Reach last")
                    
                    if self.filter == "filter" {
                        self.getGroupsByFilter()
                    }
                    else {
                        if self.isLogged {
                            print("is Logged - has Loaded More true")
                            self.getGroupsByFilter()
                        }else{
                            self.getSwiftGroups()
                            print("Not  Logged - has Loaded More false")
                            
                        }
                    }
                    
                }
            }, completion: { (finished) -> Void in
                // finish infinite scroll animations
                self.groupCollectionView.finishInfiniteScroll()
            });
        }
        
        self.tableView.addInfiniteScroll(handler: { (tableView) in
                if  self.hasLoadMore == true && !self.isLoading{
                    
                    self.isLoading = true
                    
                    print("Reach last")
                    
                    if self.filter == "filter" {
                        self.getGroupsByFilter()
                    }
                    else {
                        if self.isLogged {
                            print("is Logged - has Loaded More true")
                            self.getGroupsByFilter()
                        }else{
                            self.getSwiftGroups()
                            print("Not  Logged - has Loaded More false")
                            
                        }
                    }
                    
                }
                self.tableView.finishInfiniteScroll()
                print("Im here addInfiniteScroll")
            })
        
        
        categoryViewSelect.addTapGestureRecognizer {
            MyVriables.isCatgory = true
            if self.filterCatgory != nil {
                MyVriables.filterCatgory = self.filterCatgory
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MultiSelectViewController") as! MultiSelectViewController
            self.present(vc, animated: true, completion: nil)
            // multy
        }
        
        countyCodePickerView.textColor = UIColor.white
        phoneNumberFeild.attributedPlaceholder = NSAttributedString(string: "Enter a phone ..",
                                                            attributes: [NSAttributedString.Key.foregroundColor: Colors.whiteLight])
        searchDestantion.addTapGestureRecognizer {
            self.myTargetFunction()
        }
//        searchDestantion.addTarget(self, action: #selector(myTargetFunction), for: UIControlEvents.touchDown)
        hidePhonePicker.addTapGestureRecognizer {
             self.registerView.isHidden = false
        }
        hideSearchView.addTapGestureRecognizer {
           
            self.searchView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.searchView.isHidden = true
                self.chatView.fadeIn()
                self.inboxView.fadeIn()
                self.menuView.fadeIn()
                self.chatView.isHidden = false
                self.inboxView.isHidden = false
                self.menuView.isHidden = false
                
            })
            self.view.endEditing(true)
            
        }
        newSearcIcon.addTapGestureRecognizer {
          
            self.inboxView.fadeOut(completion: {
                (finished: Bool) -> Void in
                
                self.menuView.isHidden = true
                self.chatView.isHidden = true
                self.inboxView.isHidden = true
                self.searchView.fadeIn()
                self.searchView.isHidden = false
                
            })
            self.searchBarFilter.becomeFirstResponder()
        }
       searchBarFilter.setImage(UIImage(), for: .search, state: .normal)
       searchBarFilter.setPlaceholderTextColorTo(color: UIColor.white)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboardd")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        gridView.addTapGestureRecognizer  {
            print("mediaViewClick click")
            self.tableView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.tableView.alpha = 0
                self.groupCollectionView.fadeIn()
                self.groupCollectionView.alpha = 1
                
            })
            
            self.instgramImage.image = UIImage(named: "standardWhite")
            self.gridImage.image = UIImage(named: "gridGold")
            self.lisviewImage.image = UIImage(named: "listWhite")
        }
        instagramView.addTapGestureRecognizer {
            print("Intsa click")
            
            self.groupCollectionView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.groupCollectionView.alpha = 0
                self.tableView.fadeIn()
                self.tableView.alpha = 1
                
            })
            self.typeCell = "instaView"
            self.instgramImage.image = UIImage(named: "standardGold")
            self.gridImage.image = UIImage(named: "gridWhite")
            self.lisviewImage.image = UIImage(named: "listWhite")
            self.tableView.reloadData()
            
        }
        listView.addTapGestureRecognizer {
            self.groupCollectionView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.groupCollectionView.alpha = 0
                self.tableView.fadeIn()
                self.tableView.alpha = 1
                
            })
            print("youtubeViewClick click")
            self.typeCell = "youtubeView"
            self.instgramImage.image = UIImage(named: "standardWhite")
            self.gridImage.image = UIImage(named: "gridWhite")
            self.lisviewImage.image = UIImage(named: "listGold")
            self.tableView.reloadData()
            
        }
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        var localTimeZoneName: String { return TimeZone.current.identifier }
        
        filterButton.tintColor = Colors.PrimaryColor
        filterButton.titleLabel?.textColor = Colors.PrimaryColor
        
        
        frequncyTabs.segments = LabelSegment.segments(withTitles: grroupsType,
                                                      normalFont: UIFont(name: "HelveticaNeue-Light", size: 11.0)!,
                                                      normalTextColor: Colors.PrimaryColor,
                                                      selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
        frequncyTabs.tintColor = Colors.PrimaryColor
        
        //filterButton.currentTitleColor = Colors.PrimaryColor
        //filterButton.color
        
        instgramImage.image = UIImage(named: "standardGold")
        gridImage.image = UIImage(named: "gridWhite")
        lisviewImage.image = UIImage(named: "listWhite")
        
        print("Viewstatus Did load ")

        helpViews.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showHelp", sender: self)

        }
        filterButton.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside) //<- use `#selector(...)`
        
        fbBt.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
     
        //refreshData
        // Hide the navigation bar on the this view controller
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
      
        let defaults = UserDefaults.standard
         self.isLogged = defaults.bool(forKey: "isLogged")

        let deviceToken = UIDevice.current.identifierForVendor!.uuidString
        let countryName = Locale.current.localizedString(forRegionCode: Locale.current.regionCode!)
        print("Curretntorifin langough is \(countryName)")
        print("Device \(deviceToken)    \(countryName)")
        phoneRegisterView.addTapGestureRecognizer {
            setCheckTrue(type: "telephone_header", groupID: -1)
            self.registerView.isHidden = true
            self.phoneNumberStackView.isHidden = false
            self.chatHeaderStackView.isHidden = true
        }

        swiftEventFunc()

        SwiftEventBus.onMainThread(self, name: "facebookLogin") { result in
            self.facebookMember = result?.object as! FacebookMember
            MyVriables.kindRegstir = "facebook-Regstir"
            setCheckTrue(type: "create_member", groupID: -1)
            self.performSegue(withIdentifier: "showTerms", sender: self)
        }
        SwiftEventBus.onMainThread(self, name: "refreshNotficatons") { result in
            self.getMember(memberId: (MyVriables.currentMember?.id)!)

        }
        SwiftEventBus.onMainThread(self, name: "facebook-Regstir") { result in
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
        }
        SwiftEventBus.onMainThread(self, name: "termConfirm") { result in
            self.checkIfMember(textFeild: "\(self.contryCodeString)\(self.phoneNumberFeild.text!)",type: "phone", facebookMember: self.facebookMember)
            
        }
        
        SwiftEventBus.onMainThread(self, name: "checkMember") { result in
            print("Im here in checkmember before present")
            self.phonenumber_  = result?.object as! String
            MyVriables.kindRegstir = "phone-Regstir"
            self.performSegue(withIdentifier: "showTerms", sender: self)
        }
        SwiftEventBus.onMainThread(self, name: "termConfirm-phone-Regstir") { result in
            self.checkIfMember(textFeild: self.phonenumber_, type: "phone",facebookMember : self.facebookMember)
        }
        fPickerView.delegate = self
        fPickerView.delegate = self
        countyCodePickerView.delegate = self
        countyCodePickerView.dataSource = self
       
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        notficationView.addTapGestureRecognizer {
            if !(self.scrollFilter.isHidden) {
                self.hideFilter()
            }
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
            if !(self.scrollFilter.isHidden) {
                self.hideFilter()
            }
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
                
                self.menuImage.image = UIImage(named: "backbutton-white")
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
        
        
        chatView.addTapGestureRecognizer {
            if !(self.scrollFilter.isHidden) {
                self.hideFilter()
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Chat") as! ChatViewController
            
            self.navigationController?.pushViewController(vc,
                                                     animated: true)

           
        }
        inboxView.addTapGestureRecognizer {
            if !(self.scrollFilter.isHidden) {
                self.hideFilter()
            }
            self.performSegue(withIdentifier: "showNotifications", sender: self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        phoneNumberFeild.keyboardType = .numberPad
        setCountryPicker()
        setRefresher()
        self.checkCurrentUser()
        searchBarFilter.delegate = self
       
        setFilterView()
        setMemberMenuView()
        filtersBtton.addTarget(self, action: #selector(ViewController.navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        frequncyTabs.addTarget(self, action: #selector(ViewController.navigationSegmentedControlValueChangedd(_:)), for: .valueChanged)
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Clcikced cencel")
    }
    
    
    @objc func handleCustomFBLogin() {
        if !(self.scrollFilter.isHidden) {
            self.hideFilter()
        }
        setCheckTrue(type: "facebook_header", groupID: -1)
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if (result?.isCancelled)! {
                setCheckTrue(type: "facebook_cancel", groupID: -1)
                print("eror ")
                return
            }
            if err != nil {
                setCheckTrue(type: "facebook_cancel", groupID: -1)

             //   print("Custom FB Login failed:", err)
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
                setCheckTrue(type: "facebook_cancel", groupID: -1)
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
            
            let facebookMember2 : FacebookMember = FacebookMember(first_name: userInfo["first_name"] != nil ? userInfo["first_name"] as? String : "", last_name: userInfo["last_name"] != nil ? userInfo["last_name"] as? String : "", facebook_id: userInfo["id"] != nil ? userInfo["id"] as? String : "", facebook_profile_image: ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String)
            self.dismiss(animated: true, completion: nil)
            
            self.facebookMember = facebookMember2
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
           // SwiftEventBus.post("facebookLogin", sender: facebookMember)
        })
        
        
        //
        //
        //            print(result)
        //        }
    }
    var checkboxDialogViewController: CheckboxDialogViewController!
    typealias TranslationTuple = (name: String, translated: String)
    typealias TranslationDictionary = [String : String]
    @IBAction func showMulty(_ sender: Any) {
        let tableData :[(name: String, translated: String)] = [("Angola", "Angole"),
                                                               ("Croatia", "Croatia"),
                                                               ("Germany", "Germany"),
                                                               ("Ireland", "Ireland"),
                                                               ("Spain", "Spain"),
                                                               ("United Kingdom", "United Kingdom"),
                                                               ("Venezuela", "Venezuela"),("Angola", "Angole"),
                                                               ("Croatia", "Croatia"),
                                                               ("Germany", "Germany"),
                                                               ("Irelanda", "Ireland"),
                                                               ("Spain", "Spain"),
                                                               ("United Kingdom", "United Kingdom"),
                                                               ("Venezuela", "Venezuela")]
        
        
        self.checkboxDialogViewController = CheckboxDialogViewController()
        self.checkboxDialogViewController.titleDialog = "Countries"
        self.checkboxDialogViewController.tableData = tableData
        self.checkboxDialogViewController.defaultValues = [tableData[3]]
     
        self.checkboxDialogViewController.componentName = DialogCheckboxViewEnum.countries
        self.checkboxDialogViewController.delegateDialogTableView = self
        self.checkboxDialogViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(self.checkboxDialogViewController, animated: false, completion: nil)
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
        },to:"\(ApiRouts.Media)/api/v2/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/profile")
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
                                        let urlString =  ApiRouts.Media + path
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
   
    @IBAction func searcDestnation(_ sender: Any) {
    }
    @IBOutlet weak var searchDestantion: UITextField!
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    @IBAction func onSearchClcik(_ sender: Any) {
      present(placesSearchController, animated: true, completion: nil)
    }
    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        self.groupIndex = Int(sender.index)
    }
    @objc func navigationSegmentedControlValueChangedd(_ sender: BetterSegmentedControl) {
        self.groupBothIndex = Int(sender.index)
    }
    func checkCurrentUser(){
        print("im in check current user Func")
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        self.isLogged = defaults.bool(forKey: "isLogged")
        let phone = defaults.string(forKey: "phone")
        print("Im in  isLogged \(isLogged)")
        
        if isLogged == true{
            self.filterClickView.isHidden = false
            self.filterButton.isHidden = false
          //  self.searchbarButrnsView.isHidden = false
            self.lastitem = 0
            print("IS logged = true")
            filter = "all"
            self.getMember(memberId: id)
            setBadges()
            
            filtersBtton.segments = LabelSegment.segments(withTitles: self.groupsTypeAfterReg,
                                                          normalFont: UIFont(name: "HelveticaNeue-Light", size: 11.0)!,
                                                          normalTextColor: Colors.PrimaryColor,
                                                          selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
            

            self.filterClickView.isHidden = false
            self.filterButton.isHidden = false
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

            self.sort = standart_sort
            self.page = 1
            self.lastitem = 0
            self.myGrous = []
            self.hasLoadMore = true
          
            self.getGroupsByFilter()
         
            
            
            
            
            
        }else{
            filtersBtton.segments = LabelSegment.segments(withTitles: self.groupsTypeBeforeReg,
                                                          normalFont: UIFont(name: "HelveticaNeue-Light", size: 11.0)!,
                                                          normalTextColor: Colors.PrimaryColor,
                                                          selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
           
            self.lastitem = 0
            self.page = 1
            self.myGrous = []
            filter = "all"
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

    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selcetGroup(indexPath)
    }
    @objc func refreshData(){
        print("refresh is loading")
        self.page = 1
        self.lastitem = 0
        self.myGrous = []
        self.hasLoadMore = true
        self.tableView.reloadData()
        self.groupCollectionView.reloadData()
        if self.filter == "filter" {
            self.getGroupsByFilter()
        }
        else {
        if self.isLogged {
                self.getGroupsByFilter()
            
            
        }else{
            
                self.getSwiftGroups()
            
        }
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
        if type == "phone"{
            params = ["phone": textFeild]
            
        }
        else
        {
            params = ["facebook_id": textFeild]
            
        }
        
        HTTP.POST(ApiRouts.Api + "/members/check", parameters: params) { response in
            if response.error != nil {
                print("error \(String(describing: response.error?.localizedDescription))")
                return
            }
            do {
            let  existMember = try JSONDecoder().decode(ExistMember.self, from: response.data)
            print ("successed")
            DispatchQueue.main.sync {
               
                if (existMember.exist)! == true
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
                        MyVriables.phoneNumberr = textFeild
                        MyVriables.phoneNumber = textFeild
                    }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyDialogVc") as! PrivacyDialogVc
                            self.present(vc, animated: true, completion: nil)
                    
                   // self.performSegue(withIdentifier: "showGdbr", sender: self)
                }
            }
            }
            catch{
                
            }
            //do things...
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
        
        if !(self.scrollFilter.isHidden) {
            self.hideFilter()
        }
        
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
                MyVriables.kindRegstir = "phone"
                MyVriables.phoneNumberr = self.phoneNumber
                //self.performSegue(withIdentifier: "showTerms", sender: self)
            self.checkIfMember(textFeild: "\(self.contryCodeString)\(self.phoneNumberFeild.text!)",type: "phone", facebookMember: self.facebookMember)
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
        let deviceToken = UIDevice.current.identifierForVendor!.uuidString        
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
                params = ["device_id": deviceToken,"login_type": "ios", "facebook_id": facebookMember.facebook_id!, "type": "facebook", "first_name": facebookMember.first_name!,"last_name": facebookMember.last_name!,"facebook_profile_image": facebookMember.facebook_profile_image != nil ? facebookMember.facebook_profile_image! : nil, "gdpr":gdprArr]
            }
            else{
                params = ["device_id": deviceToken,"login_type": "ios", "facebook_id": facebookMember.facebook_id!, "type": "facebook", "first_name": facebookMember.first_name!,"last_name": facebookMember.last_name!,"facebook_profile_image": facebookMember.facebook_profile_image != nil ? facebookMember.facebook_profile_image! : nil]
            }
            
        print("Regstir Faceook id is \(facebookMember)")
        HTTP.POST(ApiRouts.Register, parameters: params) { response in
            //do things...
            if response.error != nil {
                print("im in error func \(response.error)")
                DispatchQueue.main.async {
                    let snackbar = TTGSnackbar(message: "There was an error please try again.", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                return
            }
            print("im in response func \(response.description)")
            do{
                  setCheckTrue(type: "member_logged", groupID: -1)
                let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                self.currentMember = member
                Analytics.logEvent("SignupSucess", parameters: [
                    "member_id": "\((member.member?.id)!)"
                    ])
                logSignupSucessEvent(member_id: (member.member?.id)!)
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
//                    self.tableView.reloadData()
//                    self.groupCollectionView.reloadData()
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
        sendSms(phonenum: (MyVriables.phoneNumberr)!)
        MyVriables.phoneNumberr = ""
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
            let deviceToken = UIDevice.current.identifierForVendor!.uuidString
            params = ["device_id": deviceToken,"login_type": "ios", "code": (textField?.text)!, "phone": phone]
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                if response.error != nil {
                    print(response.error)
                    DispatchQueue.main.async {
                        let snackbar = TTGSnackbar(message: "The code you entered is invaid.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                    return
                }
                print(response.description)
                do{
                    setCheckTrue(type: "sms_verification", groupID: -1)
                    setCheckTrue(type: "member_logged", groupID: -1)

                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    Analytics.logEvent("SignupSucess", parameters: [
                        "member_id": "\((member.member?.id)!)"
                        ])
                    logSignupSucessEvent(member_id: (member.member?.id)!)
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
                        self.groupCollectionView.reloadData()
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
    func getTokenReuqest() {
        var params: [String: Any] = [:]
        params = ["grant_type": "client_credentials", "client_id": "2", "scope": "", "client_secret": "YErvt0T9iPupWJfLOChPSkJKcqZKZhP0DHntkcTL"]
        let url: String = ApiRouts.Web + "/oauth/token"
        HTTP.POST(url, parameters: params) { response in
            if response.error != nil {
                //print("error \(response.error)")
                return
            }
            do {
                let accessToken : AccessToken =  try JSONDecoder().decode(AccessToken.self, from: response.data)
                let calendar = Calendar.current
                let date = calendar.date(byAdding: .second, value: accessToken.expires_in!, to : Date())
                self.setToUserDefaults(value: accessToken.access_token!, key: "access_token")
                self.setToUserDefaults(value: date, key: "expires_in")
                DispatchQueue.main.async {
                    self.getSwiftGroups()
                }
                print ("successed \(response.description)")
            }
            catch {
                
            }
        }
    }
    
    
    func getSwiftGroups(){
        let defaults = UserDefaults.standard
        let access_token = defaults.string(forKey: "access_token")
        if access_token != nil {
            if access_token != "no value"{
        print("request PAGE = \(self.page)")
        print("Im in all groups sort url ==" + ApiRouts.AllGroupsRequest +  "?page=\(self.page)&sort=created_at&order=des")
        var groups: [GroupItemObject]?
        hud.textLabel.text = ""
        hud.show(in: self.view)
         HTTP.GET(ApiRouts.ApiV3 + "/groups?page=\(self.page)&sort=created_at&order=des") { response in
            let defaults = UserDefaults.standard
            let access_token = defaults.string(forKey: "access_token")
            print("Http access token \(access_token!)")
            print(ApiRouts.AllGroupsRequest)
            if response.error != nil {
                self.hud.dismiss()
                return
            }
            let data = response.data
            do {
                let groups2 = try JSONDecoder().decode(Main.self, from: data)
                self.lastitem = self.lastitem + ((groups2 != nil) ? (groups2.data?.count)! : 0)

                print("Last item = \(self.lastitem)")
                groups = groups2.data != nil ? groups2.data! : nil
                if groups != nil {
                if (groups2.total)! == 0
                {
                    self.hud.dismiss()
                    DispatchQueue.main.async {
                        self.hasLoadMore = false
                        self.noGroupsView.isHidden = false
                    }
                    return
                }else
                {
                    DispatchQueue.main.async {
                        self.noGroupsView.isHidden = true }
                }
                DispatchQueue.main.sync {
                    for group in groups! {
                        self.myGrous.append(group)
                    }
                    self.hud.dismiss()
                    self.tableView.reloadData()
                    self.groupCollectionView.reloadData()
                    self.refresher.endRefreshing()
                    self.page += 1
                }
                DispatchQueue.main.sync {
                    if self.page > groups2.last_page!
                    {
                        self.hud.dismiss()
                        
                        self.hasLoadMore = false
                        self.refresher.endRefreshing()
                        return
                    }
                    self.isLoading = false
                    }}}
                catch {
                }}

        }else
            {
                getTokenReuqest()

            }
    }else
        {
            getTokenReuqest()
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
        print("request PAGE = \(self.page) and filter url is \(self.filterUrl)")
        var searchUrl: String = ""
        self.myGroupByPhoneView.isHidden = true
        var groups: [GroupItemObject]?
        let withoutFilter = "/groups?member_id=\(self.id)&my_groups=true&page=\(self.page)&sort=\(self.sort)"
       // let withoutFilter = "/api/groups?page=\(self.page)&sort=\(self.sort)"
        let withRole = ApiRouts.ApiV3 + "/groups/members/\(self.id)?page=\(self.page)&role=group_leader&sort=\(self.sort)"
        let daysGroup = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&filter=days&sort=\(self.sort)"
        let oneDayGroup = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&filter=day&sort=\(self.sort)"
        let allGroupsFilter = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)"
        if self.id == -1 {
            searchUrl  = ApiRouts.ApiV3 + "/groups?page=\(self.page)&sort=\(self.sort)&search=\(self.search)"
        }else {
        searchUrl  = ApiRouts.ApiV3 + "/groups?member_id=\(self.id)&page=\(self.page)&sort=\(self.sort)&search=\(self.search)"
        }
        var lastFilter: String = ""
        if filter == "all" {
            print("Im here in filter == all")
            lastFilter = allGroupsFilter
        }
        if filter == "search" {
            noGroupText.text = " We could not find groups using the search words you provided. Please try again later."
            lastFilter = searchUrl
        }
        if filter == "leader" {
             noGroupText.text = " You currently do not have any groups that you create or mange."
            lastFilter = withRole
        }
        if filter == "day" {
            noGroupText.text = " You currently do not have any groups that you create or mange."
            lastFilter = oneDayGroup
        }
        if filter == "days" {
            noGroupText.text = " You currently do not have any groups that you create or mange."
            lastFilter = daysGroup
        }
        if filter == "filter" {
            setFilterUrl()
            lastFilter = self.filterUrl
        }
        if filter == "no-filter" {
            print("Im here in filter == no-filter")
            let defaults = UserDefaults.standard
            let phone = defaults.string(forKey: "phone")
            if phone != nil && phone! != "no value" {
                myGroupByPhoneView.isHidden = true
            }else {
                myGroupByPhoneView.isHidden = false
                return
                
            }
            
            lastFilter = withoutFilter
        }
        hud.textLabel.text = ""
        hud.show(in: self.view)
        print("The url is \(lastFilter)")
        HTTP.GET(lastFilter) { response in
            if let error = response.error {
                print(error)
                self.hud.dismiss()
            }
            let data = response.data
            do {
                let  groups2 = try JSONDecoder().decode(Main.self, from: data)
               if groups2.data != nil {
                groups = groups2.data!
                print("------------- \(lastFilter)  Page: \(self.page) groups count: \(groups?.count)")
                self.lastitem = self.lastitem + (groups?.count)!

                if (groups2.total)! == 0
                {
                    self.hud.dismiss()
                    if self.filter == "no-filter" {
                        DispatchQueue.main.async {
                             self.noGroupsView.isHidden = true
                            let snackbar = TTGSnackbar(message: "You currently have no groups related to you. Check our public groups", duration: .middle)
                            self.clickes[0] = true
                            self.clickes[1] = false
                            self.clickes[2] = false
                            self.clickes[3] = false
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
               
                
                
                
                DispatchQueue.main.async {
                    for group in groups! {
                        if !self.myGrous.contains(where: { (tGroup) -> Bool in
                            return tGroup.id == group.id
                        }) {
                            self.myGrous.append(group)
                        }
                       
                    }
                    self.page = self.page + 1
                    print("FILTER URL IS \(self.filterUrl)")
                    
                    self.hud.dismiss()
                    //   self.myGrous = groups!
                    self.tableView.reloadData()
                    
                    self.groupCollectionView.reloadData()
                    
                    if self.refresher.isRefreshing{
                        self.refresher.endRefreshing()
                    }
                    //print("The url is last_page = \(groups2.last_page) and page is \(self.page)")
                    
                    
                    if self.page > groups2.last_page!
                    {
                        self.hud.dismiss()
                        
                        self.hasLoadMore = false
                        self.refresher.endRefreshing()
                        return
                    }
                    self.isLoading = false
                }
                }
            }
            catch let error  {
                print("im in catch \(error)")
                self.hud.dismiss()
                
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
        print("Url is " + ApiRouts.Api +  "/members/member/\(memberId)")
        HTTP.GET(ApiRouts.Api +  "/members/member/\(memberId)", parameters: []) { response in
            //do things...
            if response.error != nil {
                print(response.error)
                return
            }
            print(response.description)
            do{
                let  member : MyMemberInfo = try JSONDecoder().decode(MyMemberInfo.self, from: response.data)
                if response.error != nil {
                    print("Memberinfo is \(String(describing: response.error))")
                    return
                }
                self.currentMember = CurrentMember(member: member.member, profile: member.member?.profile, total_unread_messages: (member.total_unread_messages)!, total_unread_notifications: (member.total_unread_notifications)!)
                MyVriables.currentMember =  (self.currentMember?.member)!
                MyVriables.currentMember?.gdpr = member.member?.gdpr!
                print("All profile  is \((MyVriables.currentMember)!)")
                MyVriables.currentMember?.id = (member.member?.profile?.member_id)!
                print("Member id is \(MyVriables.currentMember?.id!)")
                print("Struct Gdpr : \((MyVriables.currentMember)!)")
                
                self.id = (MyVriables.currentMember?.id)!

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
                setUnreadMessages(member_id:  (MyVriables.currentMember?.id)!)
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
                         urlString = ApiRouts.Media + (profile_image)!
                            }
                        print("Url string is \(urlString)")
                            urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                            var url = URL(string: urlString!)
                        if url != nil {
                            self.profileImageView.sd_setImage(with: url!, completed: nil)
                        }
                        }
                        
                    }else
                    {
                        self.profileImageView.image = UIImage(named : "default user")
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Groups is \(self.myGrous.count)")
        return self.myGrous.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = groupCollectionView.dequeueReusableCell(withReuseIdentifier: "GroupMediaCell", for: indexPath) as! GroupMediaCell
        var currentIndex:Int = indexPath.row
        if currentIndex < (self.myGrous.count){
        if self.myGrous[currentIndex].images != nil && (self.myGrous[currentIndex].images?.count)! > 0 {
            do{
                var urlString: String = try ApiRouts.Media + (self.myGrous[currentIndex].images?[0].path)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    //                     cell.imageosh.sd_setImage(with: url, placeholderImage: UIImage(named: "Group Placeholder"), completed: nil)
                 //cell.groupImage.kf.indicatorType = .activity
                    cell.groupImage.sd_setShowActivityIndicatorView(true)
                    cell.groupImage.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    cell.groupImage.sd_setImage(with: url, completed: nil)
                    
                    
                    
                }else {
                    cell.groupImage.image = UIImage(named: "Group Placeholder")
                    print("IMAGESTATUS - in out of let - for group -  \(self.myGrous[currentIndex].translations?[0].title!) , urlString: \(urlString)")
                    
                }
                
            }
            catch{
                cell.groupImage.image = UIImage(named: "Group Placeholder")
                
            }
        } else {
            print("IMAGESTATUS - in else ")
            
            cell.groupImage.image = UIImage(named: "Group Placeholder")
        }
        if self.myGrous[currentIndex].translations?.count != 0 {
            cell.groupTitle.text = self.myGrous[currentIndex].translations?[0].title
            
        }else{
            cell.groupTitle.text = ""
        }
        }
        if self.myGrous[currentIndex].special_price != nil {
            cell.iSspecialPrice.isHidden = false
           
        }else{
            cell.iSspecialPrice.isHidden = true
        }
        return cell
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
    
 
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        if scrollView == tableView{
//
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
//            {
//                print("Im reach scroll")
//                if  self.hasLoadMore == true && !self.isLoading{
//
//                    self.isLoading = true
//
//                    print("Reach last")
//
//                    if self.filter == "filter" {
//                        self.getGroupsByFilter()
//                    }
//                    else {
//                        if isLogged {
//                            print("is Logged - has Loaded More true")
//                            self.getGroupsByFilter()
//                        }else{
//                            self.getSwiftGroups()
//                            print("Not  Logged - has Loaded More false")
//
//                        }
//                    }
//
//                }
//            }
//        }
//    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

//        print("Last item  \(indexPath.row + 1 == self.lastitem) and hasLoadMore is \(hasLoadMore) and \(!self.isLoading)")
//        if indexPath.row  == self.myGrous.count - 1 && hasLoadMore == true && !self.isLoading{
//               print("Last item is \(lastitem) and index is \(indexPath.row)")
//            self.isLoading = true
//
//            print("Reach last")
//
//            if self.filter == "filter" {
//                self.getGroupsByFilter()
//            }
//            else {
//            if isLogged {
//                print("is Logged - has Loaded More true")
//                self.getGroupsByFilter()
//            }else{
//                self.getSwiftGroups()
//                print("Not  Logged - has Loaded More false")
//
//            }
//            }
//
//        }
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        self.registerView.isHidden = false

    }
    // tableview: tableview count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("hi \(myGrous.count)")
        //return isLogged ? self.myGrous.count+1 : self.myGrous.count
        print("Groups is \(self.myGrous.count)")
        return  self.myGrous.count
    }
    
    
    // tableview: return the cell
    
    fileprivate func setGroupItmes(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        //var index = isLogged ? indexPath.row -1 : indexPath
         // var currentIndex = isLogged ? indexPath.row-1 : indexPath.row
        let currentIndex = indexPath.row
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "customCell",for: indexPath) as! CustomTableViewCell
        cell.tableviewCell.layer.cornerRadius = 1
        
        // border
        cell.tableviewCell.layer.cornerRadius = 1
        cell.tableviewCell.layer.shadowColor = UIColor.gray.cgColor
        cell.tableviewCell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.tableviewCell.layer.shadowRadius = 12.0
        cell.tableviewCell.layer.shadowOpacity = 0.7
        

        cell.viewInfo.tag = currentIndex
        cell.viewInfo.addTapGestureRecognizer(action: ShowModel)
        if self.myGrous[currentIndex].special_price != nil {
            cell.isSaleGroup.isHidden = false
            cell.newPrice.text = "£\((self.myGrous[currentIndex].special_price)!)"
            if self.myGrous[currentIndex].price != nil {
                cell.oldPrice.text = "£\((self.myGrous[currentIndex].price)!)"
                cell.slashImage.isHidden = false
            }else
            {
                cell.oldPrice.text = ""
                cell.slashImage.isHidden = true
                
            }
        }else{
            if self.myGrous[currentIndex].price != nil {
                cell.newPrice.text = "£\((self.myGrous[currentIndex].price)!)"
                cell.slashImage.isHidden = true
                cell.oldPrice.text = ""
            }else
            {
                cell.oldPrice.text = ""
                cell.slashImage.isHidden = true
                cell.newPrice.text = ""
                
            }
           cell.isSaleGroup.isHidden = true
        }
        cell.totalDaysLbl.text = self.myGrous[currentIndex].days != nil ? "\((self.myGrous[currentIndex].days)!)" : ""
        
        if self.myGrous[currentIndex].translations?.count != 0
        {
            cell.membersLbl.numberOfLines = 2
            cell.membersLbl.text = self.myGrous[currentIndex].translations?[0].destination != nil ? (self.myGrous[currentIndex].translations?[0].destination)! : ""
        }
        if self.myGrous[currentIndex].rotation != nil && (self.myGrous[currentIndex].rotation)! == "reccuring"
        {
            cell.totalDaysLbl.text = ""
            cell.daysLbl.text = ""
            cell.totalMembersLbl.text = ""
            if self.myGrous[currentIndex].start_time != nil && self.myGrous[currentIndex].end_time != nil {
                    cell.totalDaysLbl.text = "\(setFormat(date: (self.myGrous[currentIndex].start_time)!)) - \(setFormat(date: (self.myGrous[currentIndex].end_time)!))"
                }else {
                    cell.totalDaysLbl.text = " "
            }
            if self.myGrous[currentIndex].hours_of_operation != nil
            {
            
                cell.frequencyLbl.text = self.myGrous[currentIndex].frequency != nil ? "\((self.myGrous[currentIndex].frequency)!.capitalizingFirstLetter()) Tour": ""
                cell.frequencyDescrptionLbl.text = self.myGrous[currentIndex].hours_of_operation!
            }else{

                cell.frequencyLbl.text = ""
                cell.frequencyDescrptionLbl.text = ""
                
            }
            cell.ItineraryImage.isHidden = false
            //cell.membersIcon.isHidden = true
            if self.myGrous[currentIndex].frequency != nil
            {
                cell.frequencyLbl.text = self.myGrous[currentIndex].frequency != nil ? "\((self.myGrous[currentIndex].frequency)!.capitalizingFirstLetter()) Tour": ""
                cell.tagLinefrequencyView.isHidden = false
                cell.startDayLbl.text = (self.myGrous[currentIndex].frequency)!
            }else
            {
                cell.tagLinefrequencyView.isHidden = true
                cell.startDayLbl.text = "" 
            }
            
            cell.dateAndNightsLbl.text = ""
            //cell.startDayLbl.text = getStartDate(date: self.myGrous[currentIndex].start_date!)
            cell.isReccuring.image = UIImage(named: "dailyicon")
        }else
        {
            cell.dateAndNightsLbl.text = "\(self.myGrous[currentIndex].start_date!.split(separator: "-")[2]) \(getMonthName(month: String(self.myGrous[currentIndex].start_date!.split(separator: "-")[1]))) \(self.myGrous[currentIndex].start_date!.split(separator: "-")[0]) \n\((self.myGrous[currentIndex].days)!) Days"
            cell.daysLbl.text = "Days"
            cell.tagLinefrequencyView.isHidden = true
            cell.ItineraryImage.isHidden = false
            //cell.membersIcon.isHidden = true
            cell.startDayLbl.text = getStartDate(date: self.myGrous[currentIndex].start_date!)
            cell.isReccuring.image = UIImage(named: "calendar")
            
        }
        
        if currentIndex > -1 && currentIndex < self.myGrous.count {
        if self.myGrous[currentIndex].images != nil && (self.myGrous[currentIndex].images?.count)! > 0{
            do{
                var urlString: String =  ApiRouts.Media + (self.myGrous[currentIndex].images?[0].path)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    cell.imageosh.sd_setShowActivityIndicatorView(true)
                    cell.imageosh.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    cell.imageosh.sd_setImage(with: url, completed: nil)
                    
                    

                }else {
                    cell.imageosh.image = UIImage(named: "Group Placeholder")
                    print("IMAGESTATUS - in out of let - for group -  \(self.myGrous[currentIndex].translations?[0].title!) , urlString: \(urlString)")
                    
                }
                
            }
            catch{
                cell.imageosh.image = UIImage(named: "Group Placeholder")
                
            }
        } else {
            print("IMAGESTATUS - in else ")
            
            cell.imageosh.image = UIImage(named: "Group Placeholder")
        }
        
      
        
        // if company
        if self.myGrous[currentIndex].is_company == 0 {
            if self.myGrous[currentIndex].group_leader != nil {
                if self.myGrous[currentIndex].group_leader?.profile != nil {
                    cell.groupLeaderLbl.text = self.myGrous[currentIndex].group_leader?.profile?.first_name != nil ?"\((self.myGrous[currentIndex].group_leader?.profile?.first_name)!) \((self.myGrous[currentIndex].group_leader?.profile?.last_name)!)": ""
                }
            
            if self.myGrous[currentIndex].group_leader?.images != nil && (self.myGrous[currentIndex].group_leader?.images?.count)! > 0 {
                do{
                    var urlString =  ApiRouts.Media + (self.myGrous[currentIndex].group_leader?.images?[0].path)!
                    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    
                    var url = URL(string: urlString)
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.sd_setImage(with: url, completed: nil)
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
            }
           
        } // if just group leader
        else{
            if self.myGrous[currentIndex].group_leader != nil {
                if self.myGrous[currentIndex].group_leader?.profile != nil {
                    cell.groupLeaderLbl.text = self.myGrous[currentIndex].group_leader?.profile?.company_name != nil ? (self.myGrous[currentIndex].group_leader?.profile?.company_name)! : "Company"
                }
                
            
            if self.myGrous[currentIndex].group_leader?.profile?.company_image != nil{
                
                do{
                    var urlString = try ApiRouts.Media + (self.myGrous[currentIndex].group_leader?.profile?.company_image)!
                    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    var url = URL(string: urlString)
                    if url == nil {
                    }else {
                        cell.groupLeaderImageView.sd_setImage(with: url!, completed: nil)
                        
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
        }
        
        cell.selectionStyle = .none
        if self.myGrous[currentIndex].translations?.count != 0 {
            cell.groupLabel.text = self.myGrous[currentIndex].translations?[0].title
            
        }else{
            cell.groupLabel.text = ""
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
    fileprivate func youtubeGroups(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        var currentIndex = indexPath.row
        let cell : YoutubeGroupCell = tableView.dequeueReusableCell(withIdentifier: "YoutubeGroupCell",for: indexPath) as! YoutubeGroupCell
        cell.youtubeCellView.layer.cornerRadius = 1
        
        // border
        cell.youtubeCellView.layer.cornerRadius = 1
        cell.youtubeCellView.layer.shadowColor = UIColor.gray.cgColor
        cell.youtubeCellView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.youtubeCellView.layer.shadowRadius = 12.0
        cell.youtubeCellView.layer.shadowOpacity = 0.7
                if self.myGrous[currentIndex].images != nil && (self.myGrous[currentIndex].images?.count)! > 0{
                        do{
                            var urlString: String = try ApiRouts.Media + (self.myGrous[currentIndex].images?[0].path)!
                            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                            if let url = URL(string: urlString) {
                                //                     cell.imageosh.sd_setImage(with: url, placeholderImage: UIImage(named: "Group Placeholder"), completed: nil)
                             //   cell.groupImage.kf.indicatorType = .activity
                                cell.groupImage.sd_setShowActivityIndicatorView(true)
                                cell.groupImage.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                                cell.groupImage.sd_setImage(with: url, completed: nil)
        
        
        
                            }else {
                                cell.groupImage.image = UIImage(named: "Group Placeholder")
                                print("IMAGESTATUS - in out of let - for group -  \(self.myGrous[currentIndex].translations?[0].title!) , urlString: \(urlString)")
        
                            }
        
                        }
                        catch{
                            cell.groupImage.image = UIImage(named: "Group Placeholder")
        
                        }
                    } else {
                        print("IMAGESTATUS - in else ")
        
                        cell.groupImage.image = UIImage(named: "Group Placeholder")
                    }
        
        if self.myGrous[currentIndex].rotation != nil && (self.myGrous[currentIndex].rotation)! == "reccuring"
        {
            cell.date.text  = ""
            cell.members.textColor = Colors.PrimaryColor
              cell.members.text = self.myGrous[currentIndex].frequency != nil ? "\((self.myGrous[currentIndex].frequency)!.capitalizingFirstLetter()) Tour": ""
        }else
        {
            cell.members.textColor = UIColor.black


            
            cell.date.text = "\(self.myGrous[currentIndex].start_date!.split(separator: "-")[2]) \(getMonthName(month: String(self.myGrous[currentIndex].start_date!.split(separator: "-")[1]))) \(self.myGrous[currentIndex].start_date!.split(separator: "-")[0])"
            cell.members.text = "\((self.myGrous[currentIndex].days!)) Days"
        }
        if self.myGrous[currentIndex].translations?.count != 0 {
            cell.groupTitle.text = self.myGrous[currentIndex].translations?[0].title
            
        }else{
            cell.groupTitle.text = ""
        }
        if self.myGrous[currentIndex].special_price != nil {
            cell.isSaleGroup.isHidden = false
            cell.newPrice.text = "£\((Int(self.myGrous[currentIndex].special_price!)))"
            if self.myGrous[currentIndex].price != nil {
                cell.oldPrice.text = "£\(((self.myGrous[currentIndex].price!)))"
                cell.slashImage.isHidden = false
            }else
            {
                cell.oldPrice.text = ""
                cell.slashImage.isHidden = true
                
            }
        }else{
            if self.myGrous[currentIndex].price != nil {
                cell.newPrice.text = "£\(((self.myGrous[currentIndex].price!)))"
                cell.slashImage.isHidden = true
                cell.oldPrice.text = ""
            }else
            {
                cell.oldPrice.text = ""
                cell.slashImage.isHidden = true
                cell.newPrice.text = ""
                
            }
            cell.isSaleGroup.isHidden = true
        }
        
     
//            cell.startDayLbl.text = getStartDate(date: self.myGrous[currentIndex].start_date!)
//            cell.totalDaysLbl.text = "\(getTotalDays(start: self.myGrous[currentIndex].start_date!, end: self.myGrous[currentIndex].end_date!))"
//            if self.myGrous[currentIndex].target_members != nil{
//                cell.totalMembersLbl.text = "\(self.myGrous[currentIndex].target_members!)"
//            }else{
//                if self.myGrous[currentIndex].max_members != nil {
//                    cell.totalMembersLbl.text = "\(self.myGrous[currentIndex].max_members!)"
//                }
//            }
        
        
        
//
//            // if company
        
//        if self.myGrous[currentIndex].is_company == 0 {
//            if self.myGrous[currentIndex].group_leader != nil {
//                if self.myGrous[currentIndex].group_leader?.profile != nil {
//                    cell.groupleadername.text = self.myGrous[currentIndex].group_leader?.profile?.first_name != nil ?"\((self.myGrous[currentIndex].group_leader?.profile?.first_name)!) \((self.myGrous[currentIndex].group_leader?.profile?.last_name)!)": ""
//                }
//                
//                if self.myGrous[currentIndex].group_leader?.images != nil && (self.myGrous[currentIndex].group_leader?.images?.count)! > 0 {
//                    do{
//                        var urlString =  ApiRouts.Media + (self.myGrous[currentIndex].group_leader?.images?[0].path)!
//                        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
//                        
//                        var url = URL(string: urlString)
//                        if url == nil {
//                        }else {
//                            cell.groupleaderIm.sd_setImage(with: url!, completed: nil)
//                            cell.groupleaderIm.layer.cornerRadius = cell.groupleaderIm.frame.size.width / 2;
//                            cell.groupleaderIm.clipsToBounds = true;
//                            cell.groupleaderIm.layer.borderWidth = 1.0
//                            cell.groupleaderIm.layer.borderColor = UIColor.gray.cgColor
//                            cell.groupleaderIm.contentMode = .scaleAspectFill
//                        }
//                    }
//                    catch let error{
//                    }
//                    
//                }
//                else
//                {
//                    cell.groupleaderIm.image = UIImage(named: "default user")
//                    cell.groupleaderIm.layer.borderWidth = 0
//                    cell.groupleaderIm.layer.cornerRadius = 0;
//                    cell.groupleaderIm.clipsToBounds = false;
//                }
//            }
//            
//        } // if just group leader
//        else{
//            if self.myGrous[currentIndex].group_leader != nil {
//                if self.myGrous[currentIndex].group_leader?.profile != nil {
//                    cell.groupleadername.text = self.myGrous[currentIndex].group_leader?.profile?.company_name != nil ? (self.myGrous[currentIndex].group_leader?.profile?.company_name)! : "Company"
//                }
//                
//                
//                if self.myGrous[currentIndex].group_leader?.profile?.company_image != nil{
//                    
//                    do{
//                        var urlString = try ApiRouts.Media + (self.myGrous[currentIndex].group_leader?.profile?.company_image)!
//                        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
//                        var url = URL(string: urlString)
//                        if url == nil {
//                        }else {
//                            cell.groupleaderIm.sd_setImage(with: url!, completed: nil)
//                            
//                        }
//                    }catch {
//                        
//                    }
//                }
//                else
//                {
//                    cell.groupleaderIm.image = UIImage(named: "group tools title")
//                }
//                cell.groupleaderIm.layer.borderWidth = 0
//                cell.groupleaderIm.layer.cornerRadius = 0;
//                cell.groupleaderIm.clipsToBounds = false;
//                cell.groupleaderIm.contentMode = .scaleAspectFit
//            }
//        }
//            cell.selectionStyle = .none
//            if self.myGrous[currentIndex].translations?.count != 0 {
//                cell.groupTitle.text = self.myGrous[currentIndex].translations?[0].title
//
//            }else{
//                cell.groupTitle.text = ""
//        }
//        cell.members.text =  self.myGrous[currentIndex].target_members != nil ? "\((self.myGrous[currentIndex].target_members)!) Members" : ""

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeCell == "instaView"
        {
            return setGroupItmes(tableView, indexPath)

        }
        else
        {
            return youtubeGroups(tableView,indexPath)

        }
//        if isLogged
//        {
//            if indexPath.row != 0 {
//                return setGroupItmes(tableView, indexPath)
//            }
//            else {
//                let cell : SearchGroupViewCell = tableView.dequeueReusableCell(withIdentifier: "searchCell",for: indexPath) as! SearchGroupViewCell
//                cell.search_bar.delegate = self
//                cell.search_bar.searchBarStyle = .minimal;
//                return cell
//            }
//        }
//        else{
//          return setGroupItmes(tableView, indexPath)
//        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print(searchBar.text)
            if !(self.scrollFilter.isHidden) {
                self.hideFilter()
            }
            self.myGroupsBt.setTitleColor(UIColor.black, for: .normal)
            self.publicGroupsbt.setTitleColor(UIColor.black, for: .normal)
            self.multiDaysBt.setTitleColor(UIColor.black, for: .normal)
            self.managamentBt.setTitleColor(UIColor.black, for: .normal)
            self.allGroupsBt.setTitleColor(UIColor.black, for: .normal)
            self.oneDayBt.setTitleColor(UIColor.black, for: .normal)
            self.closeFilterSlide()
            sort = "created_at&order=desc"
            search = (searchBar.text)!
            search = search.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            self.page = 1
            self.lastitem = 0
            self.myGrous = []
            self.hasLoadMore = true
            //searchBar.text = ""
            if (searchBar.text)! == ""
            {
                let defaults = UserDefaults.standard
                let isLogged = defaults.bool(forKey: "isLogged")
                if isLogged == true{
                    self.getGroupsByFilter()
                }else{
                    filter = "all"
                    self.getSwiftGroups()
                }
            }else
            {
                filter = "search"
            }
            self.tableView.reloadData()
            self.groupCollectionView.reloadData()
            ARSLineProgress.hide()
            self.getGroupsByFilter()
        //self.refreshData()
            view.endEditing(true)
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField , let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {
            
            if let img3 = clearButton.image(for: .highlighted) {
                clearButton.isHidden = false
                let tintedClearImage = img3.imageWithColor(color1: UIColor.white)
                clearButton.setImage(tintedClearImage, for: .normal)
                clearButton.setImage(tintedClearImage, for: .highlighted)
            }else{
                clearButton.isHidden = true
            }
            clearButton.addTarget(self, action: #selector(ViewController.handleSend), for: .touchUpInside)
        }
        
    }
    @objc func handleSend(_ sender: UIGestureRecognizer){
        self.page = 1
        self.lastitem = 0
        self.myGrous = []
        self.hasLoadMore = true
        filter = "all"
        self.tableView.reloadData()
        self.groupCollectionView.reloadData()
        self.getGroupsByFilter()
        ARSLineProgress.hide()
        //self.refreshData()
        view.endEditing(true)
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
    
    func getGroup(group_id: Int , member_id : Int){
        var urlstring: String?
        if member_id != -1 {
            urlstring = ApiRouts.ApiV3 + "/groups/\((group_id))?member_id=\((member_id))"
        }else {
            urlstring = ApiRouts.ApiV3 + "/groups/\((group_id))"
        }
        print("Url string is \(urlstring!)")

        self.hud.show(in: self.view)
        HTTP.GET((urlstring)!){response in
            if response.error != nil {
                self.hud.dismiss()
                return
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                MyVriables.currentGroup = group2.group
               setCheckGroupTrue(member_id: (MyVriables.currentMember?.id)!, groupID: (MyVriables.currentGroup?.id)!)
                DispatchQueue.main.sync {
                    MyVriables.currentGroup = group2.group
                    self.hud.dismiss()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MainTap") as! MainTabController
                    
                    self.navigationController?.pushViewController(vc,                  animated: true)
                    
                    let params: [String: Any] = ["member_id": (MyVriables.currentMember?.id!)! , "group_id": (MyVriables.currentGroup?.id!)! , "type": ApiRouts.VisitGroupType]
                    print("PARAMS - \(params)")
                    ApiRouts.actionRequest(parameters: params)
                    
                }
            }
            catch let error{
                self.hud.dismiss()
                print("getGroup : \(error)")
                
            }
        }
    }
    fileprivate func selcetGroup(_ indexPath: IndexPath) {
        var currentIndex = indexPath.row
        let pasteboard = UIPasteboard.general
        if let string = pasteboard.string {
            // text was found and placed in the "string" constant
            print("clipboard: "+string)
        }
        //        var currentIndex = isLogged ? indexPath.row-1 : indexPath.row
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
            
            if self.myGrous[currentIndex].role  == nil {
                if isOpen {
                    getGroup(group_id: (self.myGrous[currentIndex].id)! , member_id: (MyVriables.currentMember?.id)!)
                }else {
                    showCloseAlert()
                }
            }else{
                // must to set group
                getGroup(group_id: (self.myGrous[currentIndex].id)! , member_id: (MyVriables.currentMember?.id)!)
                // do some
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        if indexPath.row + 1 == self.myGrous.count && hasLoadMore == true && !self.isLoading{
            print("Last item is \(lastitem) and index is \(indexPath.row)")
            self.isLoading = true
            
            print("Reach last")
            if self.filter == "filter" {
                self.getGroupsByFilter()
            }else {
            if isLogged {
                print("is Logged - has Loaded More true")
                self.getGroupsByFilter()
            }else{
                print("Filter is \(self.filter)")
                self.getSwiftGroups()
                print("Not  Logged - has Loaded More false")
                
            }
            }
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selcetGroup(indexPath)
        
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
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
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
        sendSms(phonenum: (MyVriables.phoneNumberr)!)
        MyVriables.phoneNumberr = ""
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
            let deviceToken = UIDevice.current.identifierForVendor!.uuidString
            params = ["device_id": deviceToken,"login_type": "ios", "code": (textField?.text)!, "phone": MyVriables.phoneNumber!, "gdpr":gdprArr
            ]
            print("Parmas is \(params)")
            print("GDPR = \(MyVriables.arrayGdpr!)")
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                if response.error != nil {
                    print(response.error)
                    DispatchQueue.main.async {
                        let snackbar = TTGSnackbar(message: "The code you entered is invaid.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                    return
                }
                print(response.description)
                do{
                    setCheckTrue(type: "sms_verification", groupID: -1)
                    setCheckTrue(type: "member_logged", groupID: -1)

                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    Analytics.logEvent("SignupSucess", parameters: [
                        "member_id": "\((member.member?.id)!)"
                        ])
                    logSignupSucessEvent(member_id: (member.member?.id)!)
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
                        self.groupCollectionView.reloadData()
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
        self.groupCollectionView.reloadData()
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
extension UITraitCollection {
    
    var isIpad: Bool {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var isIphoneLandscape: Bool {
        return verticalSizeClass == .compact
    }
    
    var isIphonePortrait: Bool {
        return horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var isIphone: Bool {
        return isIphoneLandscape || isIphonePortrait
    }
}
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
        
    }
    
    func fadeOut(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
extension UISearchBar
{
    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
}
extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
}
