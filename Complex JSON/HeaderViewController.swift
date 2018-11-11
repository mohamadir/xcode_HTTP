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



class HeaderViewController: UIViewController,UITextFieldDelegate,  CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate
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
                
                        MyVriables.phoneNumberr =  self.contryCodeString+self.phoneLbl.text!
                        MyVriables.currentPhoneNumber = self.contryCodeString+self.phoneLbl.text!
                        self.checkIfMember(textFeild: (MyVriables.currentPhoneNumber)!,type: "phone", facebookMember: self.facebookMember)

                
                
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
        let strMethod = String(format : ApiRouts.Api + "/check_if_member" )
        if type == "phone"{
            params = ["phone": textFeild]
            
        }
        else
        {
            params = ["facebook_id": textFeild]
            
        }
        HTTP.POST(ApiRouts.Api + "/members/check", parameters: params) { response in
            if response.error != nil {
                print("error \(response.error?.localizedDescription)")
                return
            }
            do {
                let  existMember = try JSONDecoder().decode(ExistMember.self, from: response.data)
                print ("successed")
                DispatchQueue.main.sync {
                    
                    self.view.endEditing(true)

                    print("Member is checked == \((existMember.exist)!)")
                    if (existMember.exist)! == true
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
                            print("Im here from facebook")
                            MyVriables.facebookMember = facebookMember
                            self.view.endEditing(true)

                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyDialogVc") as! PrivacyDialogVc
                            self.present(vc, animated: true, completion: nil)
                        }else {
                            print("Im here from phone")

                            MyVriables.facebookMember = nil
//                            self.dismiss(animated: true,completion: nil)
                            MyVriables.phoneNumber = textFeild
                            MyVriables.phoneNumberr = textFeild
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyDialogVc") as! PrivacyDialogVc
                            self.present(vc, animated: true, completion: nil)

                        }
                       
                        
                    }
                }
            }
            catch{
                
            }
            //do things...
        }
        

        
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.registerView.isHidden = false
        self.chatView.isHidden = true
        self.inboxView.isHidden = true
        self.pickerView.isHidden = true
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
        countryPickerView.textColor = UIColor.white
        
        phoneLbl.attributedPlaceholder = NSAttributedString(string: "Enter a phone ..",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
     // phoneLbl.setPlaceholderTextColorTo(color: UIColor.white)
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        print("ISLOGGED = \(isLogged)")
        if isLogged == true{
            pickerView.isHidden = true
            self.registerView.isHidden = true
            self.chatView.isHidden = false
            self.inboxView.isHidden = false
            
        }else {
            self.registerView.isHidden = false
            self.chatView.isHidden = true
            self.inboxView.isHidden = true
           // pickerView.isHidden = false
        }
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code

    
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
        
        SwiftEventBus.onMainThread(self, name: "changeProfileInfoHeader") { result in
            self.pickerView.isHidden = true
            self.registerView.isHidden = true
            self.chatView.isHidden = false
            self.inboxView.isHidden = false
            
        }
        SwiftEventBus.onMainThread(self, name: "facebookLogin2") { result in
            MyVriables.kindRegstir = "facebook-Header"
            self.facebookMember = result?.object as! FacebookMember
            setCheckTrue(type: "create_member", groupID: -1)
            self.performSegue(withIdentifier: "showTerms", sender: self)
            
        }
        SwiftEventBus.onMainThread(self, name: "facebook-Header") { result in
            self.facebookMember = result?.object as! FacebookMember
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
            
        }
        SwiftEventBus.onMainThread(self, name: "refreshGroupRolee") { result in
            self.pickerView.isHidden = true
            self.registerView.isHidden = true
            self.phoneRegisterView.isHidden = true
            self.chatView.isHidden = false
            self.inboxView.isHidden = false
        }

        SwiftEventBus.onMainThread(self, name: "phone-Header") { result in
            //self
            print("Contry code is \((MyVriables.currentPhoneNumber)!)")
            self.checkIfMember(textFeild: (MyVriables.currentPhoneNumber)!,type: "phone", facebookMember: self.facebookMember)
            
        }
        SwiftEventBus.onMainThread(self, name: "refreshHeader") { result in
            print("Im here in refresh header")
            self.pickerView.isHidden = true
            self.registerView.isHidden = true
            self.chatView.isHidden = false
            self.inboxView.isHidden = false
        }
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        print("ISLOGGED = \(isLogged)")
        if isLogged == true{
            pickerView.isHidden = true
            self.registerView.isHidden = true
            self.chatView.isHidden = false
            self.inboxView.isHidden = false
            
        }
        backView.addTapGestureRecognizer {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
       
        
        phoneRegisterView.addTapGestureRecognizer {
            setCheckTrue(type: "telephone_header", groupID: -1)
            self.registerView.isHidden = true
            self.chatView.isHidden = true
            self.inboxView.isHidden = true
            self.pickerView.isHidden = false

        }


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
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                //do things...
                if response.error != nil {
                    print(response.error)
                    DispatchQueue.main.async {
                        let snackbar = TTGSnackbar(message: "There was an error please try again.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                    return
                }
                print(response.description)
                do{
                    setCheckTrue(type: "member_logged", groupID: -1)
                    let  member = try JSONDecoder().decode(CurrentMember.self, from: response.data)
                    print(member)
                    self.currentMember = member
                    self.setToUserDefaults(value: true, key: "isLogged")
                    Analytics.logEvent("SignupSucess", parameters: [
                        "member_id": "\((member.member?.id)!)"
                        ])
                    logSignupSucessEvent(member_id: (member.member?.id)!)
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
                        self.view.endEditing(true)
                        self.getGroup(memberId: "\((self.currentMember?.member?.id!)!)")
                        //SwiftEventBus.post("refreshGroupRole")
                        SwiftEventBus.post("changeProfileInfoHeader")
                      
                        if Messaging.messaging().fcmToken != nil {
                            MyVriables.TopicSubscribe = true
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-CHAT-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-INBOX-\(String(describing: (self.currentMember?.member?.id!)!))")
                            
                            Messaging.messaging().subscribe(toTopic: "/topics/IOS-SYSTEM-\(String(describing: (self.currentMember?.member?.id!)!))")
                        }

                    }
                    MyVriables.isMember = true
                    
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = true
                        self.registerView.isHidden = true
                        self.chatView.isHidden = false
                        self.inboxView.isHidden = false
                    }
                    SwiftEventBus.post("refreshGroupRolee")

                    
                }
                catch {
                    print("catch error")
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = false
                        self.registerView.isHidden = false
                        self.chatView.isHidden = true
                        self.inboxView.isHidden = true
                    }
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
            
            print ("pin 111111111111111")
            
            let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
            print ("pin 2")
            textField?.delegate = self
            self.PINCODE = textField?.text
            print("Header PIN CODE : \((textField?.text)!) and phone is \(phone)")
            var params: [String: Any] = [:]
            let deviceToken = UIDevice.current.identifierForVendor!.uuidString
            params = ["device_id": deviceToken,"login_type": "ios", "code": (textField?.text)!, "phone": phone]
            MyVriables.currentPhoneNumber = ""
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
                    
                    DispatchQueue.main.async {
                        SwiftEventBus.post("refreshGroupRolee")
                        SwiftEventBus.post("refreshHeader")
                    }
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
                    self.setToUserDefaults(value: self.currentMember?.total_unread_messages, key: "chat_counter")
                    self.setToUserDefaults(value: self.currentMember?.total_unread_notifications, key: "inbox_counter")
                    
                    MyVriables.shouldRefresh = true
                    self.currentProfile = self.currentMember?.profile!
                    DispatchQueue.main.sync {
                        self.view.endEditing(true)

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
                        self.chatView.isHidden = false
                        self.inboxView.isHidden = false
                    }
                    

                    

                    
                }
                catch {
                    print("catch error")
                    DispatchQueue.main.async {
                        self.pickerView.isHidden = false
                        self.registerView.isHidden = false
                        self.chatView.isHidden = true
                        self.inboxView.isHidden = true

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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func getGroup(memberId: String){
        
        HTTP.GET(ApiRouts.ApiV3 + "/groups/\((MyVriables.currentGroup?.id != nil ? MyVriables.currentGroup?.id! : -1)!)?member_id=\((memberId))"){response in
            if response.error != nil {
                print("response eror")
            return
            }
            do {
                print("response sucess")
            let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
            MyVriables.currentGroup = group2.group
            DispatchQueue.main.async {
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
        sendSms(phonenum: (MyVriables.phoneNumberr)!)
        MyVriables.phoneNumberr = ""
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
            let deviceToken = UIDevice.current.identifierForVendor!.uuidString
            params = ["device_id": deviceToken,"login_type": "ios", "code": (textField?.text)!, "phone": MyVriables.currentPhoneNumber!, "gdpr":gdprArr
            ]
            MyVriables.currentPhoneNumber = ""
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
                    self.currentMember = member
                    Analytics.logEvent("SignupSucess", parameters: [
                        "member_id": "\((member.member?.id)!)"
                        ])
                    logSignupSucessEvent(member_id: (member.member?.id)!)
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
                
                    SwiftEventBus.post("refreshGroupRolee")

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
                            self.chatView.isHidden = false
                            self.inboxView.isHidden = false

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
                        self.chatView.isHidden = true
                        self.inboxView.isHidden = true

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
        setCheckTrue(type: "facebook_header", groupID: -1)
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                 setCheckTrue(type: "facebook_cancel", groupID: -1)
                print("Custom FB Login failed:", err)
                return
            }
            if (result?.isCancelled)! {
                 setCheckTrue(type: "facebook_cancel", groupID: -1)
                print("eror ")
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
             print("Access token is \(FBSDKAccessToken.current())")
            let facebookMember : FacebookMember = FacebookMember(first_name: userInfo["first_name"] != nil ? userInfo["first_name"] as? String : "", last_name: userInfo["last_name"] != nil ? userInfo["last_name"] as? String : "", facebook_id: userInfo["id"] != nil ? userInfo["id"] as? String : "", facebook_profile_image: ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String)
            self.dismiss(animated: true, completion: nil)
            self.facebookMember = facebookMember
            self.checkIfMember(textFeild: (self.facebookMember?.facebook_id!)!, type: "facebook_id",facebookMember: self.facebookMember)
          //  SwiftEventBus.post("facebookLogin2", sender: facebookMember)
            
        })
    
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
     
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

   

}

