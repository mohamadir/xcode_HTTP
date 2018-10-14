//
//  SignUpVC.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyAvatar
import SwiftyPickerPopover
import SwiftHTTP
import SwiftEventBus
import TTGSnackbar
import PhoneNumberKit
import CountryPickerView
import FBSDKLoginKit
import FBSDKCoreKit

class SignUpVC: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate {

    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
       // self.flagImageView.image = flag
        //self.countryPrefLable.text = phoneCode
    }
    var phone: String = ""
    @IBOutlet weak var heightFacebookView: NSLayoutConstraint!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var phoneNumberConstarate: NSLayoutConstraint!
    @IBOutlet weak var countyCodePickerView: CountryPickerView!
    var contryCodeString : String = ""
    var contryCode : String = ""
    var minimumDate : Date?
    var maximumDate : Date?
    var valueSelected : String = ""
    var valueSelectedIndex : Int = 0
    @IBOutlet weak var fbBt: UIButton!
    @IBOutlet weak var birthdayBt: UIButton!
    @IBOutlet weak var firstNameTf: SkyFloatingLabelTextField!
    var pickerData: [String] = []
    @IBOutlet weak var gender: UIPickerView!
    @IBOutlet weak var profileImage: SwiftyAvatar!
    @IBOutlet weak var phoneTf: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTf: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTf: SkyFloatingLabelTextField!
    @IBOutlet weak var birthday: UIDatePicker!
    var dateString: String?
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
        
    }
 
   
    fileprivate func setFontType(_ tf: SkyFloatingLabelTextField) {
        tf.font = UIFont(name: "Arial", size: 14)
        tf.titleFont = UIFont(name: "Arial", size: 14)!
        tf.placeholderFont = UIFont(name: "Arial", size: 14)
    }
    @IBOutlet weak var viewChangebt: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countyCodePickerView.delegate = self
        countyCodePickerView.dataSource = self
        countyCodePickerView.font =  UIFont(name: "Arial", size: 14)!
         fbBt.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        countyCodePickerView.textColor = Colors.grayColor
        self.emailTf.autocorrectionType = .no
        self.firstNameTf.autocorrectionType = .no
        self.lastNameTf.autocorrectionType = .no
        self.phoneTf.autocorrectionType = .no
        self.emailTf.delegate = self
        
        self.firstNameTf.delegate = self
        self.lastNameTf.delegate = self
        self.phoneTf.delegate = self
        countyCodePickerView.showPhoneCodeInView = true
        countyCodePickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        let defaults = UserDefaults.standard
        let profile_image = defaults.string(forKey: "profile_image")
        let firstName = defaults.string(forKey: "first_name")
        let lastName = defaults.string(forKey: "last_name")
        self.phone = defaults.string(forKey: "phone")!
        let email = defaults.string(forKey: "email")
        let gender = defaults.string(forKey: "gender")
         let birth_date = defaults.string(forKey: "birth_date")
        if firstName != "no value"{ // last == "no value" {
        firstNameTf.text = firstName
        }
        if lastName != "no value" {
        lastNameTf.text = lastName
        }
        if MyVriables.currentMember?.facebook_id != nil
        {
            if MyVriables.currentMember?.facebook_id! != ""
            {
                self.fbBt.isHidden = true
                self.heightFacebookView.constant = 0
                self.facebookView.isHidden = true
            }
        }
        if birth_date != nil {
           if birth_date != "no value" {
            birthdayBt.setTitle(birth_date!, for: .normal)
            }
        }
        if emailTf.text != nil {
            if email != "no value" {
            emailTf.text = email
            }
        }
        if gender != nil {
            getGenderIndex(gender: gender!)
        }
        else {
            self.pickerData = ["Male", "Female", "other"]
        }
       
        setFontType(lastNameTf)
        setFontType(firstNameTf)
        setFontType(phoneTf)
        setFontType(emailTf)
        set18YearValidation()
        self.gender.delegate = self
        self.gender.dataSource = self
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year,.month], from: date as Date)
        let startOfMonth = calendar.date(from: components)
        if profile_image != nil {
            if profile_image! != "no value"{
                let urlString: String
                if profile_image!.contains("http")
                {
                    urlString = (profile_image)!

                }
                else
                {
                    urlString =  ApiRouts.Web + (profile_image)!

                }
            var url = URL(string: urlString)
            if url != nil {
                self.profileImage.sd_setImage(with: url!, completed: nil)
            }
            }
            
        }
        if self.phone != "no value"{
            phoneTf.text = phone
            phoneNumberConstarate.constant = 10
            
            countyCodePickerView.isHidden = true
            phoneTf.isEnabled = false
            countyCodePickerView.isUserInteractionEnabled = false
        }else{
            phoneNumberConstarate.constant = 91
            countyCodePickerView.isHidden = false
        countyCodePickerView.isUserInteractionEnabled = true
            phoneTf.isEnabled = true
            
            
        }
        
        
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    @IBAction func showPicker(_ sender: UIButton) {
      
        
        /// Create StringPickerPopover:
        let p = DatePickerPopover(title: "Birth Date")
            p.setDateMode(.date)
        let currentDate: Date = Date()

        p.setMaximumDate(self.maximumDate!)
        p.setMinimumDate(self.minimumDate!)
           p.setSelectedDate(Date())
        p.setDoneButton(color: Colors.PrimaryColor, action: { popover, selectedDate in print("selectedDate \(selectedDate + 1)")
                
                self.dateString = selectedDate.description
                var myString: String = self.dateString!;
                var myStringArr = myString.components(separatedBy: " ")
                
              self.birthdayBt.setTitle(self.setDate(mydateis: myStringArr [0]), for: .normal)
            })
        
            p.setCancelButton(color: Colors.PrimaryColor, action: { _, _ in
                print("cancel")})
            p.appear(originView: sender, baseViewController: self)
    
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
        var finalDate = tomorrow?.description.components(separatedBy: " ")
        return finalDate![0]
    }
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -5

        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    }

    
    @IBAction func saveProfileInfo(_ sender: Any) {
        print("data is \(valueSelected)")
        if firstNameTf.text == "" || lastNameTf.text == ""
        {
            let snackbar = TTGSnackbar(message: "Please fill first name and last name", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
        else
        {
            saveProfileRequset()
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Arial", size: 14)
            pickerLabel?.textAlignment = .center

        }
        pickerLabel?.text = pickerData[row]
        pickerLabel?.textColor = UIColor.gray
        
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        valueSelectedIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                return pickerData[row]
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
    func getGenderIndex (gender: String){
        switch gender.lowercased() {
        case "male":
            self.pickerData = ["Male", "Female", "other"]
            break
        case "female":
            self.pickerData = ["Female","Male", "other"]
            break
        case "other":
            self.pickerData = ["other","Female","Male"]
            break
        default:
            self.pickerData = ["Male", "Female", "other"]
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
    var phoneNumber: String = ""
    fileprivate func updateProfileRequset(_ params: inout [Dictionary<String, Any>]) {
        if self.firstNameTf.text != ""
        {
            params.append(["first_name": self.firstNameTf.text!])
        }
        if self.lastNameTf.text != ""
        {
            params.append(["last_name": self.lastNameTf.text!])
        }
//        if self.emailTf.text != ""
//        {
//            params.append(["email": self.emailTf.text!])
//        }
        params.append(["gender": pickerData[valueSelectedIndex]])
        if (birthdayBt.titleLabel?.text)! != "yyyy-mm-dd" {
            print("Im here and birthday is \((birthdayBt.titleLabel?.text)!)")
            params.append(["birth_date": (birthdayBt.titleLabel?.text)!])
        }
        //print("--- BT IS "+(birthdayBt.titleLabel?.text)!)
        print("params is \(params)")
        print("url for paramas is " + ApiRouts.Web + "/api/members/\((MyVriables.currentMember?.id!)!)")
        HTTP.PUT(ApiRouts.Api+"/members/\((MyVriables.currentMember?.id!)!)"
            , parameters: params)
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("RESPONSE "+response.description)
            do {
                DispatchQueue.main.sync {
                    if self.firstNameTf.text != ""
                    {
                        self.setToUserDefaults(value: self.firstNameTf.text , key: "first_name")
                    }
                    if self.lastNameTf.text != ""
                    {
                        self.setToUserDefaults(value: self.lastNameTf.text , key: "last_name")
                        
                    }
                    if self.emailTf.text != ""
                    {
                        self.setToUserDefaults(value: self.emailTf.text , key: "email")
                        
                    }
                    if self.birthdayBt.titleLabel?.text != "yyyy-mm-dd"
                    {
                        print("BT IS "+(self.birthdayBt.titleLabel?.text)!)
                        self.setToUserDefaults(value: (self.birthdayBt.titleLabel?.text)!, key: "birth_date")
                        
                    }
                    self.setToUserDefaults(value: self.pickerData[self.valueSelectedIndex], key: "gender")
                    SwiftEventBus.post("changeProfileInfo")
                    self.dismiss(animated: true,completion: nil)
                    
                }
                
            }
            catch {
                
            }
        }
    }
    
    func saveProfileRequset(){
        var params = [[String: Any]]()
        if self.phone == "no value"
        {
            if self.phoneTf.text! != ""
            {
                DispatchQueue.main.async {
                    if self.isValidPhone(phone: self.contryCodeString+self.phoneTf.text!)
                    {
                        self.phoneNumber = self.contryCodeString+self.phoneTf.text!
                        if self.contryCodeString == "+972" {
                            if self.phoneTf.text!.count > 4 && self.phoneTf.text![0...0] == "0" {
                                self.phoneTf.text!.remove(at: self.phoneTf.text!.startIndex)
                                self.phoneNumber = "\(self.contryCodeString)\(self.phoneTf.text!)"
                                print("yes im inside \(self.phoneNumber)")
                            }
                        }
                        let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.phoneNumber)", preferredStyle: .alert)
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
                                        return
                                    }
                                    print("error \(response.error?.localizedDescription)")
                                    return
                                }
                                print ("successed")
                                DispatchQueue.main.sync {
                                    //
                                    self.setToUserDefaults(value: self.phoneNumber, key: "phone")
                                    self.updateProfileRequset(&params)

                                    print("Phone number is \(self.phoneNumber)")
                                }
                            }
                        }))
                        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
                            print("no")
                        }))
                        self.present(VerifyAlert, animated: true, completion: nil)
                    }else
                    {
                        let snackbar = TTGSnackbar(message: "The phone number you selected is invalid", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                }
            }
            else
            {
                updateProfileRequset(&params)

            }
        }else{
            updateProfileRequset(&params)
        }
       
        
        
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
        var params = [[String: String]]()
        var facebookMember : FacebookMember?
        print("No Error")
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request?.start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("Failed to start graph request:", error)
                return
            }
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            print("user indfo \(userInfo)")
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                let url = URL(string: imageURL)
            }
             facebookMember = FacebookMember(first_name: userInfo["first_name"] != nil ? userInfo["first_name"] as? String : "", last_name: userInfo["last_name"] != nil ? userInfo["last_name"] as? String : "", facebook_id: userInfo["id"] != nil ? userInfo["id"] as? String : "", facebook_profile_image: ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String)
            
           // self.dismiss(animated: true, completion: nil)
            if facebookMember?.facebook_id! != ""
            {
                params.append(["facebook_id": (facebookMember?.facebook_id!)!])
            
            if facebookMember?.first_name! != ""
            {
                params.append(["first_name": (facebookMember?.first_name!)!])
            }
            if facebookMember?.last_name! != ""
            {
                params.append(["last_name": (facebookMember?.last_name!)!])
            }
            if facebookMember?.facebook_profile_image! != ""
            {
                params.append(["facebook_profile_image": (facebookMember?.facebook_profile_image!)!])
            }
            HTTP.PUT(ApiRouts.Api+"/members/\((MyVriables.currentMember?.id!)!)"
                , parameters: params)
            { response in
                if let err = response.error {
                    DispatchQueue.main.async {
                        let snackbar = TTGSnackbar(message: "This Facebook account is already linked to a different account.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                   
                    print("Im after snack pabrasd")
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                print("RESPONSE "+response.description)
                do {
                    DispatchQueue.main.sync {
                        if facebookMember?.first_name! != ""
                        {
                            self.firstNameTf.text = facebookMember?.first_name!
                             self.setToUserDefaults(value: facebookMember?.first_name! , key: "first_name")
                        }
                        if facebookMember?.last_name! != ""
                        {
                            self.setToUserDefaults(value: facebookMember?.last_name!, key: "last_name")
                            self.lastNameTf.text = facebookMember?.last_name!
                        }
                        if facebookMember?.facebook_profile_image != nil && facebookMember?.facebook_profile_image != ""
                        {
                             let urlString: String
                            urlString = (facebookMember?.facebook_profile_image!)!
                             var url = URL(string: urlString)
                            if url != nil {
                                self.profileImage.sd_setImage(with: url!, completed: nil)
                            }
                            self.setToUserDefaults(value: (facebookMember?.facebook_profile_image!)!, key: "facebook_profile_image")
                        }
                        self.heightFacebookView.constant = 0
                        self.facebookView.isHidden = true
                        SwiftEventBus.post("changeProfileInfo")
                        //self.dismiss(animated: true,completion: nil)
                        
                    }
                    
                }
                catch {
                    
                }
            }
            }
            
            
        })
       

    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    

    
}
extension Date {
    /// Returns a Date with the specified days added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var targetDay: Date
        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
        return targetDay
    }
    
    /// Returns a Date with the specified days subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let inverseYears = -1 * years
        let inverseMonths = -1 * months
        let inverseDays = -1 * days
        let inverseHours = -1 * hours
        let inverseMinutes = -1 * minutes
        let inverseSeconds = -1 * seconds
        return add(years: inverseYears, months: inverseMonths, days: inverseDays, hours: inverseHours, minutes: inverseMinutes, seconds: inverseSeconds)
    }
    
}


