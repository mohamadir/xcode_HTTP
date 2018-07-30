//
//  HeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftEventBus
import CountryPickerView
import PhoneNumberKit
import TTGSnackbar
import SwiftHTTP
import Alamofire
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import FBSDKLoginKit
import FBSDKCoreKit



class HeaderViewController: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate
{
   
    
    var facebookMember : FacebookMember?

    var currentProfile: MemberProfile?
    var currentMember: CurrentMember?
    var PINCODE: String?
    var contryCodeString : String = ""
    var contryCode : String = ""
    var phoneNumber: String?

    @IBOutlet weak var fbBt: UIButton!
    @IBOutlet var backView: UIView!
    @IBOutlet var pickerView: UIView!
    @IBOutlet var countryPickerView: CountryPickerView!
    @IBOutlet var inboxCounterLbl: UILabel!
    @IBOutlet var InboxCounterView: DesignableView!
    @IBOutlet var chatCounterLbl: UILabel!
    @IBOutlet var ChatCounterView: DesignableView!
    @IBOutlet var chatView: UIView!
    @IBOutlet var inboxView: UIView!
    @IBOutlet var phoneLbl: UITextField!
    @IBOutlet weak var phoneRegisterView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var facebookRegisterView: UIView!
   
    @IBAction func sendClick(_ sender: Any) {

//        if contryCodeString == "+972" {
//            if self.phoneLbl.text!.count > 4 && self.phoneLbl.text![0...0] == "0"
//            {
//                self.phoneLbl.text!.remove(at: self.phoneLbl.text!.startIndex)
//                self.phoneNumber = "\(self.contryCodeString)\(self.phoneLbl.text!)"
//                print("yes im inside \(self.phoneNumber)")
//
//
//            }
//        }
        
        
        
        print("isValidPhone \(isValidPhone(phone: contryCodeString+phoneLbl.text!))")
        print("Contry Code is \(contryCodeString)")
        if isValidPhone(phone: contryCodeString+phoneLbl.text!)
        {
           

            self.phoneNumber = contryCodeString+phoneLbl.text!
            
            if contryCodeString == "+972" {
                if self.phoneLbl.text!.count > 4 && self.phoneLbl.text![0...0] == "0"
                {
                    self.phoneLbl.text!.remove(at: self.phoneLbl.text!.startIndex)
                    self.phoneNumber = "\(self.contryCodeString)\(self.phoneLbl.text!)"
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
                        MyVriables.kindRegstir = "phone-Header"
                        self.performSegue(withIdentifier: "showTerms", sender: self)
//                        self.checkIfMember(textFeild: self.phoneNumber!,type: "phone", facebookMember: self.facebookMember)
                        
                        
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
    var isFacebookGdpr: Bool = false

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
                    
                    MyVriables.fromGroup = "true"
                    if type != "phone"{
                        MyVriables.facebookMember = facebookMember
                    }else {
                        MyVriables.facebookMember = nil
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "refreshGroupRolee") { result in
            //self
             self.pickerView.isHidden = true
            self.registerView.isHidden = true

        }
        SwiftEventBus.onMainThread(self, name: "phone-Header") { result in
            //self
            self.checkIfMember(textFeild: self.phoneNumber!,type: "phone", facebookMember: self.facebookMember)
        }
        SwiftEventBus.onMainThread(self, name: "facebookLogin2") { result in
            MyVriables.kindRegstir = "facebook-Header"
            self.facebookMember = result?.object as! FacebookMember
            self.performSegue(withIdentifier: "showTerms", sender: self)
            
        }
        SwiftEventBus.onMainThread(self, name: "facebook-Header") { result in
            
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
            
        }
        fbBt.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)

//        facebookRegisterView.addTapGestureRecognizer {
//            print("Im clicked hereeee")
//            FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
//                if err != nil {
//                    print("Custom FB Login failed:", err)
//                    return
//                }
//
//                self.showEmailAddress()
//            }
//        }
        
        //refreshGroupRolee
        
    }
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
         self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        print(country)
        contryCodeString = country.phoneCode
        contryCode = country.code
    }
    override func viewWillAppear(_ animated: Bool) {
        setBadges()
        backView.addTapGestureRecognizer {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
       
        
        phoneRegisterView.addTapGestureRecognizer {
            self.registerView.isHidden = true
            self.pickerView.isHidden = false

        }

//        facebookRegisterView.addTapGestureRecognizer {
//            print("Im clicked hereeee")
//            FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
//                if err != nil {
//                    print("Custom FB Login failed:", err)
//                    return
//                }
//
//                self.showEmailAddress()
//            }
//        }
        SwiftEventBus.onMainThread(self, name: "refreshFromGroup") { result in
            if result?.object != nil {
                self.facebookMember = result?.object as! FacebookMember
                self.isFacebookGdpr = true
                self.regstirFacebook(facebookMember: self.facebookMember!, isGdpr:  self.isFacebookGdpr)
                
            }else {
                self.showPinDialogGdpr()

            }
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        let isLogged = defaults.bool(forKey: "isLogged")
        print("ISLOGGED = \(isLogged)")
        if isLogged == true{
            pickerView.isHidden = true
            self.registerView.isHidden = true

        }else {
            self.registerView.isHidden = false

            pickerView.isHidden = false
        }
        SwiftEventBus.onMainThread(self, name: "counters") { (result) in
            self.setBadges()
        }
        
        inboxView.addTapGestureRecognizer {
            print("INBOX PRESSE")
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Notifications") as? MemberInboxViewController {
                
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        chatView.addTapGestureRecognizer {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as? ChatViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        print("IM HERE FROM NOTF AND CHAT")
    }
    
    
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

    @IBAction func backPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                //do things...
                if response.error != nil {
                    print(response.error)
                    return
                }
                print(response.description)
                do{
                    self.view.endEditing(true)
                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    SwiftEventBus.post("refreshGroupRolee")
                    self.currentMember = member
                    self.setToUserDefaults(value: true, key: "isLogged")
                    //  print(self.currentMember?.profile!)
                    self.setToUserDefaults(value: self.currentMember?.member?.id!, key: "member_id")
                    self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                    self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                    self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                    self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                    self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                    self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                    self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                    
                    self.currentProfile = self.currentMember?.profile != nil ? self.currentMember?.profile! : nil
                    DispatchQueue.main.sync {
                        self.getGroup(memberId: "\((self.currentMember?.member?.id!)!)")
                        //SwiftEventBus.post("refreshGroupRole")
                        SwiftEventBus.post("changeProfileInfoHeader")
                        SwiftEventBus.unregister(self, name: "changeProfileInfoHeader")

                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.member?.id!)!))")
                        }
                        //                                    self.phoneNumberStackView.isHidden = true
                        //                                    self.chatHeaderStackView.isHidden = false
                        //                                }
                    }
                    MyVriables.isMember = true
                    
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = true
                        self.registerView.isHidden = true
                    }
                    
                }
                catch {
                    print("catch error")
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = false
                        self.registerView.isHidden = false
                    }
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
                    self.view.endEditing(true)

                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    SwiftEventBus.post("refreshGroupRolee")
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
                    
                    MyVriables.shouldRefresh = true
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                        self.getGroup(memberId: "\((self.currentMember?.profile?.member_id!)!)")
                        //SwiftEventBus.post("refreshGroupRole")
                        SwiftEventBus.post("changeProfileInfo")
                        SwiftEventBus.post("refreshData")
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.member?.id!)!))")
                        }
                        //                                    self.phoneNumberStackView.isHidden = true
                        //                                    self.chatHeaderStackView.isHidden = false
                        //                                }
                    }
                    MyVriables.isMember = true
                    
                    DispatchQueue.main.async {
                         self.pickerView.isHidden = true
                        self.registerView.isHidden = true
                    }
                    
                }
                catch {
                    print("catch error")
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = false
                        self.registerView.isHidden = false

                    }
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
    func getGroup(memberId: String){
        HTTP.GET(ApiRouts.Web + "/api/groups/\((MyVriables.currentGroup?.id != nil ? MyVriables.currentGroup?.id! : -1)!)/details/\(memberId)"){response in
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
            self.changeStatusTo(type: (MyVriables.currentGroup?.role!)!)
            }
          
            }
            }
            catch let error{
            print("getGroup : \(error)")
            
            }
            }
    }
    func changeStatusTo(type: String){
        if type == "member" {
            MyVriables.roleStatus = "member"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinedIcon1")
            self.tabBarController?.tabBar.items![1].title = "Joined"
            self.tabBarController?.selectedIndex = 0
             MyVriables.isAvailble = true
        }
        else {
        if type == "observer" {
            MyVriables.roleStatus = "observer"
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinicon1")
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
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "timeout")
                self.tabBarController?.tabBar.items![1].title = "Closed"
                self.tabBarController?.tabBar.items![1].selectedImage =   UIImage(named: "timeout")
                 MyVriables.isAvailble = false
            }
            else
            {
                MyVriables.roleStatus = "null"
                self.tabBarController?.tabBar.items![1].image = UIImage(named: "joinicon1")
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
    public func showPinDialogGdpr() {
        // dismiss(animated: true, completion: nil)
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created")
        
        PinAlert.addTextField { (textField) in
            textField.placeholder = "1234"
            
        }
        print ("pin created")
        
        PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
             self.view.endEditing(true)
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
                    self.view.endEditing(true)
                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    self.currentMember = member
                    self.setToUserDefaults(value: true, key: "isLogged")
                    //  print(self.currentMember?.profile!)
                    self.setToUserDefaults(value: self.currentMember?.member?.id!, key: "member_id")
                    self.setToUserDefaults(value: self.currentMember?.profile?.first_name , key: "first_name")
                    self.setToUserDefaults(value: self.currentMember?.profile?.last_name, key: "last_name")
                    self.setToUserDefaults(value: self.currentMember?.member?.email, key: "email")
                    self.setToUserDefaults(value: self.currentMember?.member?.phone, key: "phone")
                    self.setToUserDefaults(value: self.currentMember?.profile?.gender, key: "gender")
                    self.setToUserDefaults(value: self.currentMember?.profile?.birth_date, key: "birth_date")
                    self.setToUserDefaults(value: self.currentMember?.profile?.profile_image, key: "profile_image")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                     MyVriables.shouldRefresh = true
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                        SwiftEventBus.post("changeProfileInfo")
                        SwiftEventBus.post("refreshData")
                        SwiftEventBus.post("refreshGroupRole")
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.member?.id!)!))")
                        }
             
                        DispatchQueue.main.async {
                            self.pickerView.isHidden = true
                            self.registerView.isHidden = true

                        }
                        //                                    self.chatHeaderStackView.isHidden = false
                        //
                        
                    }
                    
                    MyVriables.isMember = true
                    
                    
                }
                catch {
                    DispatchQueue.main.async {
                            self.pickerView.isHidden = false
                        self.registerView.isHidden = false

                    }
       
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
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err)
                return
            }
            
            self.showEmailAddress()
        }
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
            
            SwiftEventBus.post("facebookLogin2", sender: facebookMember)
        })
        
        
        //
        //
        //            print(result)
        //        }
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
     
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

   

}
