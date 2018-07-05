//
//  JoinViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/22/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import SkyFloatingLabelTextField
import Toast_Swift
import FirebaseMessaging
import FirebaseInstanceID
import PhoneNumberKit
import SwiftEventBus
import TTGSnackbar
import CountryPickerView
import Alamofire

class JoinViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CountryPickerViewDelegate, CountryPickerViewDataSource{
   
    @IBOutlet weak var member_view: UIView!
    @IBOutlet weak var leaveText: UILabel!
    @IBOutlet weak var leaveGrouoBt: UIButton!
    @IBOutlet weak var regstrtionCloseLbl: UILabel!
    @IBOutlet weak var viewNoJoin: UIView!
    var currentProfile: MemberProfile?
    var currentMember: CurrentMember?
    var PINCODE: String?
    var contryCodeString : String = ""
    var contryCode : String = ""
    var phoneNumber: String?
    @IBOutlet weak var constaratPickerView: NSLayoutConstraint!
    @IBOutlet weak var pickerView: CountryPickerView!
    @IBOutlet weak var lastNameTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTextFeild: SkyFloatingLabelTextField!
    var gender: String = "Male"
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var phoneTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var observerView: UIView!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var viewBack: UIView!
    let genderData: [String] = ["Male","Female","Other"]
    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftEventBus.onMainThread(self, name: "refreshFromGroupJoin") { result in
            print("fromGdpr12")
            self.showPinDialog()
        }
        SwiftEventBus.onMainThread(self, name: "joinGroup") { result in
            print("fromGdpr")
            self.showPinDialog()
        }
        //joinGroup
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        
        member_view.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 0
        }
        viewBack.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 0

        }
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        firstNameTextFeild.delegate = self
        phoneTextFeild.delegate = self
        lastNameTextFeild.delegate = self
        view.addGestureRecognizer(tap)
        phoneTextFeild.title = "Phone Number"
        phoneTextFeild.placeholder = " phone Number"
        firstNameTextFeild.title = "First Name"
        firstNameTextFeild.placeholder = " First Name"
        lastNameTextFeild.title = "Last Name"
        lastNameTextFeild.placeholder = " Last Name"
        setFontType(phoneTextFeild)
         setFontType(firstNameTextFeild)
         setFontType(lastNameTextFeild)
//        if (MyVriables.currentMember?.id)! == -1 {
//            self.phoneTextFeild.isEnabled = false
//        }
//        else {
            //self.phoneTextFeild.isEnabled = false
        //}
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == true{
            self.phoneTextFeild.isEnabled = false
            constaratPickerView.constant = 20
            pickerView.isHidden = true
        }else {
            self.phoneTextFeild.isEnabled = true
            constaratPickerView.constant = 93
            pickerView.isHidden = false
        }
      
    }
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.setNavigationBarHidden(false, animated: animated)
    }
   
    override func viewWillDisappear(_ animated: Bool) {
             self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    fileprivate func setFontType(_ tf: SkyFloatingLabelTextField) {
        tf.font = UIFont(name: "Arial", size: 16)
        tf.titleFont = UIFont(name: "Arial", size: 16)!
        tf.placeholderFont = UIFont(name: "Arial", size: 16)
    }
    func showToast(_ message: String,_ duration: Double){
        var style = ToastStyle()
        // this is just one of many style options
        style.messageColor = .white
        // present the toast with the new style
        self.view.makeToast(message, duration: duration, position: .bottom, style: style)
    }
    

    func getGroup(){
        print("Url is " + ApiRouts.Web + "/api/groups/\((MyVriables.currentInboxMessage?.group_id!)!)/details/\((MyVriables.currentMember?.id!)!)")
        HTTP.GET(ApiRouts.Web + "/api/groups/\((MyVriables.currentInboxMessage?.group_id!)!)/details/\((MyVriables.currentMember?.id!)!)"){response in
            if response.error != nil {
                return
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                MyVriables.currentGroup = group2.group
                DispatchQueue.main.sync {
                  
                    if MyVriables.currentGroup?.role != nil {
                        self.changeStatusTo(type: (MyVriables.currentGroup?.role!)!)
                    }
                      print("Role is \((MyVriables.currentGroup?.role!)!)")
                }
            }
            catch let error{
                print("getGroup : \(error)")
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("roleStatus" +  MyVriables.roleStatus)
        pickerView.delegate = self
        regstrtionCloseLbl.text = "Registration to \((MyVriables.currentGroup?.translations?[0].title)!) has been closed.Please contact the group leader."
        pickerView.dataSource = self
        pickerView.showPhoneCodeInView = true
        pickerView.showCountryCodeInView = false
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        print("my vairbels : : \(MyVriables.isAvailble)")
        setObserverPage()
        if MyVriables.currentGroup?.role != nil {
        if (MyVriables.currentGroup?.role)! == "member" || (MyVriables.currentGroup?.role)! == "group_leader" {
            observerView.isHidden = true
             viewNoJoin.isHidden = true
            memberView.isHidden = false
            if (MyVriables.currentGroup?.role)! == "group_leader"
            {
                
                leaveText.text = "You are the owner of this group."
                +
                "To edit or update the group, invite members and more, please sign in to the Snapgroup on the web."
               leaveGrouoBt.isHidden = true
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
                self.tabBarController?.tabBar.items![1].title = "Manage"
                self.tabBarController?.tabBar.items![1].selectedImage =  UIImage(named: "joinedFooter")
            }
            else
            {
                leaveText.text = "You are now a member of this group, do you want to leave group ?"
                 leaveGrouoBt.isHidden = false
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
                self.tabBarController?.tabBar.items![1].title = "Joined"
                self.tabBarController?.tabBar.items![1].selectedImage =  UIImage(named: "joinedFooter")
            }
          

            
            
        }
        else {
            print("My vairbels \(MyVriables.isAvailble)")
            if MyVriables.isAvailble == false
            {
                viewNoJoin.isHidden = false
                observerView.isHidden = true
                memberView.isHidden = true
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "timeout25")
                self.tabBarController?.tabBar.items![1].title = "Registration closed"
                self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "timeout25")
            }
            else {
                
                viewNoJoin.isHidden = true
                observerView.isHidden = false
                memberView.isHidden = true
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
            self.tabBarController?.tabBar.items![1].title = "join"
            self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "join group")
            
            }
        }
        }
        else
        {
            if MyVriables.isAvailble == false
            {
                viewNoJoin.isHidden = false
                observerView.isHidden = true
                memberView.isHidden = true
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "timeout25")
                self.tabBarController?.tabBar.items![1].title = "Registration closed"
                self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "timeout25")
            }
          
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.firstNameTextFeild.endEditing(true)
        self.lastNameTextFeild.endEditing(true)
        self.phoneTextFeild.endEditing(true)
        return false
    }
    func setObserverPage(){
        
        let defaults = UserDefaults.standard

        let id = defaults.integer(forKey: "member_id")
        let first = defaults.string(forKey: "first_name")
        let last = defaults.string(forKey: "last_name")
        let email = defaults.string(forKey: "email")
        let phone = defaults.string(forKey: "phone")
        
        if first == "no value" || last == "no value"
        {
            
        }
        else {
            self.firstNameTextFeild.text = first
             self.lastNameTextFeild.text = last
            
        }
       
        self.phoneTextFeild.text = phone
        
       
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
    @IBAction func joinGroup(_ sender: Any) {
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        if isLogged == false{
              if firstNameTextFeild.text != "" && lastNameTextFeild.text != "" && phoneTextFeild.text != "" {
                
            if isValidPhone(phone: contryCodeString+phoneTextFeild.text!)
            {
                
                
                self.phoneNumber = contryCodeString+phoneTextFeild.text!
                
                if contryCodeString == "+972" {
                    if self.phoneTextFeild.text!.count > 4 && self.phoneTextFeild.text![0...0] == "0"
                    {
                        self.phoneTextFeild.text!.remove(at: self.phoneTextFeild.text!.startIndex)
                        self.phoneNumber = "\(self.contryCodeString)\(self.phoneTextFeild.text!)"
                        print("yes im inside \(self.phoneNumber)")
                        
                        
                    }
                }
                
                let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.phoneNumber!)", preferredStyle: .alert)
                if contryCodeString == "+972" {
                    print("asd")
                }
                
                VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
                    let params = ["phone": self.phoneNumber!]
                    
                    HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
                        if response.error != nil {
                            print("error \(response.error?.localizedDescription)")
                            return
                        }
                        print ("successed")
                        DispatchQueue.main.sync {
                            //
                            self.checkIfMember(phone:  self.phoneNumber!)
                            
                            
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
              else {
                let snackbar = TTGSnackbar(message: "Please fill all the feilds", duration: .middle)
                snackbar.icon = UIImage(named: "AppIcon")
                snackbar.show()
            }
            
        }
        else {
            
            if firstNameTextFeild.text != "" && lastNameTextFeild.text != "" && phoneTextFeild.text != "" {
                
                if MyVriables.roleStatus == "observer" {
                    joinGroupRequest(memberid: (MyVriables.currentMember?.id)!)
                }
                else {
                    changeStatusTo(type: "observer")
                    
                }
            }
            else {
                let snackbar = TTGSnackbar(message: "Please fill all the feilds", duration: .middle)
                snackbar.icon = UIImage(named: "AppIcon")
                snackbar.show()
            }
        }
      


    }
    func checkIfMember(phone: String) {
        let strMethod = String(format : ApiRouts.Web + "/api/check_if_member" )
        
        let params: [String : Any] = ["phone": phone]
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
                print("RESPONSE \(response.description)")
                
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                //callback(response.result.value as? NSMutableDictionary,error as NSError?)
                break
            }
            }
            .responseString { response in
                if (response.result.value!.range(of: "true") != nil)
                {
                    
                    self.showPinDialog()
                    
                }else {
                    MyVriables.phoneNumber = phone
                    self.dismiss(animated: true,completion: nil)
                    MyVriables.fromGroup = "true-1"
                    
                    self.performSegue(withIdentifier: "showGdbr", sender: self)
                }
                
        }
        
    }
    public func showPinDialog() {
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created from join")
        
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
            if (MyVriables.fromGroup)! == "true-1" {
                let gdprArr: [String: Bool] = ["chat_messaging":(MyVriables.arrayGdpr?.chat_messaging)!,
                                               "files_upload":(MyVriables.arrayGdpr?.files_upload)!,
                                               "groups_relations":(MyVriables.arrayGdpr?.groups_relations)!,
                                               "pairing":(MyVriables.arrayGdpr?.pairing)!,
                                               "phone_number":(MyVriables.arrayGdpr?.phone_number)!,
                                               "profile_details":(MyVriables.arrayGdpr?.profile_details)!,
                                               "push_notifications":(MyVriables.arrayGdpr?.push_notifications)!,
                                               "real_time_location":(MyVriables.arrayGdpr?.real_time_location)!,
                                               "rating_reviews":(MyVriables.arrayGdpr?.rating_reviews)!]
                 params = ["code": (textField?.text)!, "phone": self.phoneNumber!, "gdpr":gdprArr]
                
            }
            else
            {
                
                 params = ["code": (textField?.text)!, "phone": self.phoneNumber!]
            }
            
           
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
                    
                    SwiftEventBus.post("refreshGroupRolee")
                    self.currentMember = member
            

                    MyVriables.shouldRefresh = true
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
                    if (MyVriables.fromGroup)! == "true-1"
                    {
                        self.joinGroupRequest(memberid: (self.currentMember?.profile?.member_id)!)
                        MyVriables.fromGroup = ""
                        
                    }
                     MyVriables.fromGroup = ""
                    DispatchQueue.main.sync {
                        self.getGroup(memberId: "\((self.currentMember?.profile?.member_id!)!)")
                        //SwiftEventBus.post("refreshGroupRole")
                        SwiftEventBus.post("changeProfileInfo")
                        SwiftEventBus.post("refreshData")
                        self.joinGroupRequest(memberid : (self.currentMember?.profile?.member_id)!)
                        
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.profile?.member_id!)!))")
                        }
                        //                                    self.phoneNumberStackView.isHidden = true
                        //                                    self.chatHeaderStackView.isHidden = false
                        //                                }
                    }
                    MyVriables.isMember = true
                    
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = true
                    }
                    
                }
                catch {
                    print("catch error")
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = false
                    }
                    self.setToUserDefaults(value: false, key: "isLogged")
                    
                }
                
            }
            
             self.view.endEditing(true)
            
            
        }))
        print ("pin after ok ")
        
        PinAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCLE", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
             MyVriables.fromGroup = ""
             self.view.endEditing(true)
        }))
        print ("pin after no ")
        self.present(PinAlert, animated: true, completion: nil)
        
        print ("pin after present ")
    }
    func getGroup(memberId: String){
        print("Url is " + ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/details/\(memberId)")
        HTTP.GET(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/details/\(memberId)"){response in
            if response.error != nil {
                print("response eror")
                return
            }
            do {
                print("response sucess")
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                MyVriables.currentGroup = group2.group
                DispatchQueue.main.async {
                    print("Role is \((MyVriables.currentGroup?.role!)!)")
                    if MyVriables.currentGroup?.role != nil {
//                        self.changeStatusTo(type: (MyVriables.currentGroup?.role!)!)
                    }
                    
                }
            }
            catch let error{
                print("getGroup : \(error)")
                
            }
        }
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
    
    func joinGroupRequest(memberid: Int){


        HTTP.POST(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\(memberid)/join", parameters: ["first_name" : self.firstNameTextFeild.text , "last_name" : self.lastNameTextFeild.text ]) { response in
            if response.error != nil {
                print("errory \(response.error?.localizedDescription)")
                
                return
            }else{
                DispatchQueue.main.sync {
                    
                    MyVriables.currentGroup?.role = "member"
                    SwiftEventBus.post("refreshGroupChangeRole")
                    SwiftEventBus.post("changeProfileInfo")

                    //changeProfileInfo
                    print("Sucess and role after  = \(MyVriables.currentGroup?.role!)")
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")
                        Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")

                    }
                    MyVriables.shouldRefresh = true
                    self.showToast("You'v left the group successfully", 0.3)
                    self.changeStatusTo(type: "member")
                    self.setToUserDefaults(value: self.firstNameTextFeild.text , key: "first_name")
                    self.setToUserDefaults(value: self.lastNameTextFeild.text, key: "last_name")
                    }
                print("descc "+response.description)
        
                }
            }
    }
    
    @IBAction func leaveGroup(_ sender: Any) {
        print(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave"+"    JOIN GROUP")
        HTTP.DELETE(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id!)!)/members/\((MyVriables.currentMember?.id!)!)/leave") { response in
            //do things...
            if response.error != nil {
                print("errory \(response.error)")
                return
            }else{
                print("descc "+response.description)
                DispatchQueue.main.sync {
                    SwiftEventBus.post("refreshGroupChangeRole")
                    MyVriables.currentGroup?.role = "observer"

                    
                    if Messaging.messaging().fcmToken != nil {
                        MyVriables.TopicSubscribe = true
                        MyVriables.CurrentTopic = "IOS-Group-\(String(describing: (MyVriables.currentGroup?.id!)!))"
                        print("/topics/\(MyVriables.CurrentTopic)")
                        Messaging.messaging().unsubscribe(fromTopic: "/topics/IOS-GROUP-\(String(describing: (MyVriables.currentGroup?.id!)!))")
                    }
                    
                    self.showToast("You'v joind the group successfully", 0.3)
                    self.leaveGroupRequest()
                }
            }
        }
    }
    
    
    func leaveGroupRequest(){
        print("LEAVE GROUP REQUEST PRESSED")
        MyVriables.shouldRefresh = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeStatusTo(type: String){
        if type == "member" {
            MyVriables.roleStatus = "member"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedFooter")
            self.tabBarController?.tabBar.items![1].title = "Joined"
            self.tabBarController?.selectedIndex = 0
            MyVriables.isAvailble = true
        }
        else {
            if type == "observer" {
                MyVriables.roleStatus = "observer"
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
                self.tabBarController?.tabBar.items![1].title = "Join"
                self.tabBarController?.selectedIndex = 0
                MyVriables.isAvailble = true
                
            }
            else {
                if type == "group_leader" {
                    MyVriables.roleStatus = "group_leader"
                    self.tabBarController?.tabBar.items![1].image = UIImage(named: "joined")
                    self.tabBarController?.tabBar.items![1].title = "Manage"
                    self.tabBarController?.selectedIndex = 0
                    MyVriables.isAvailble = true
                    
                }
                else {
                    if type == "null" {
                        if MyVriables.isAvailble == false {
                            self.tabBarController?.tabBar.items![1].image = UIImage(named: "timeout25")
                            self.tabBarController?.tabBar.items![1].title = "Registration closed"
                            self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "timeout25")
                            MyVriables.isAvailble = false
                        }
                        else
                        {
                            MyVriables.roleStatus = "null"
                            self.tabBarController?.tabBar.items![1].image = UIImage(named: "join group")
                            self.tabBarController?.tabBar.items![1].title = "Join"
                            self.tabBarController?.selectedIndex = 0
                            MyVriables.isAvailble = true
                        }
                    }
                }
            }
        }
        SwiftEventBus.post("roleChanges")
    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        print(country)
        contryCodeString = country.phoneCode
        contryCode = country.code
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender = genderData[row]
        print(gender)
    }

}
