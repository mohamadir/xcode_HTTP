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


class SignUpVC: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
       // self.flagImageView.image = flag
        //self.countryPrefLable.text = phoneCode
    }
    
    @IBOutlet weak var countyCodePickerView: CountryPickerView!
    var contryCodeString : String = ""
    var contryCode : String = ""
    var minimumDate : Date?
    var maximumDate : Date?
    var valueSelected : String = ""
    var valueSelectedIndex : Int = 0
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
         let phone = defaults.string(forKey: "phone")
        let email = defaults.string(forKey: "email")
        let gender = defaults.string(forKey: "gender")
         let birth_date = defaults.string(forKey: "birth_date")
        if firstName != "no value"{ // last == "no value" {
        firstNameTf.text = firstName
        }
        if lastName != "no value" {
        lastNameTf.text = lastName
        }
        if birth_date != nil {
            print("BIRTHDAY \(birth_date)")
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
        if phone != "no value"{
            phoneTf.text = phone
            phoneTf.isEnabled = false
            countyCodePickerView.isUserInteractionEnabled = false
        }else{
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
        components.year = -18
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
    func saveProfileRequset(){
        

        var params = [[String: Any]]()
        if self.firstNameTf.text != ""
        {
            params.append(["first_name": self.firstNameTf.text])
        }
        if self.lastNameTf.text != ""
        {
            params.append(["last_name": self.lastNameTf.text])
        }
        if self.emailTf.text != ""
        {
            params.append(["email": self.emailTf.text])
        }
        params.append(["gender": pickerData[valueSelectedIndex]])
        params.append(["member_id": (MyVriables.currentMember?.id)!])
        if (birthdayBt.titleLabel?.text)! != "yyyy-mm-dd" {
             params.append(["birthdate": (birthdayBt.titleLabel?.text)!])
        }
        
        print("--- BT IS "+(birthdayBt.titleLabel?.text)!)
        HTTP.POST(ApiRouts.Web+"/api/joingroupdetails/\((MyVriables.currentMember?.id!)!)"
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


