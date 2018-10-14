//
//  EditCompanionModal.swift
//  Snapgroup
//
//  Created by snapmac on 04/09/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyPickerPopover
import TTGSnackbar
import ARSLineProgress
import SwiftHTTP
import SwiftEventBus

class EditCompanionModal: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
   
    var valueSelectedIndex : Int = 0
    var pickerData: [String] = ["Male", "Female", "other"]
    @IBOutlet weak var lastName: SkyFloatingLabelTextField!
    @IBOutlet weak var firstName: SkyFloatingLabelTextField!
    @IBOutlet weak var birthdayBt: UIButton!
    @IBOutlet weak var gender: UIPickerView!
    var minimumDate : Date?
    var maximumDate : Date?
    var dateString: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        getGenderIndex(gender: MyVriables.currentComapnion.gender!)
        set18YearValidation()
        self.gender.delegate = self
        self.gender.dataSource = self
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.firstName.text = MyVriables.currentComapnion.first_name!
        self.lastName.text = MyVriables.currentComapnion.last_name!
    self.birthdayBt.setTitle(MyVriables.currentComapnion.birth_date!, for: .normal)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func dismissModal(_ sender: Any) {
        MyVriables.currentComapnion.id = -1
        self.dismiss(animated: false, completion: nil)
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

    @IBAction func updateClick(_ sender: Any) {
        if firstName.text! != "" && lastName.text! != ""{
            if (MyVriables.currentComapnion.id)! != -1 {
                MyVriables.currentComapnion.first_name = (firstName.text)!
                MyVriables.currentComapnion.last_name = (lastName.text)!
                MyVriables.currentComapnion.birth_date = (birthdayBt.titleLabel?.text)!

                updateCompanionFunc()
            }else{
                
            MyVriables.currentComapnion = CompanionInfo(first_name: firstName.text!, last_name: lastName.text!, group_id: MyVriables.currentGroup?.id!, gender: pickerData[valueSelectedIndex], birth_date: birthdayBt.titleLabel?.text!, id: -1)
            SwiftEventBus.post("companionUpdated")
            self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            let snackbar = TTGSnackbar(message: "You must fill all feilds", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
        
    }
    func updateCompanionFunc(){
        ARSLineProgress.show()
        let parameter : Dictionary<String,String> =  ["first_name" : (MyVriables.currentComapnion.first_name)!,"last_name" : (MyVriables.currentComapnion.last_name)!,"birth_date" : (MyVriables.currentComapnion.birth_date)!]
        print("params is \(parameter)")
        let url = ApiRouts.Api+"/members/companions/\((MyVriables.currentComapnion.id)!)"
        HTTP.PUT(url, parameters: parameter) { response in
            ARSLineProgress.hide()
            print(response.description)
            if let err = response.error {
                print("error: \(err)")
                DispatchQueue.main.sync {
                    let snackbar = TTGSnackbar(message: "In order to see the members list, please sign in at the top bar", duration: .long)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                return //also notify app of failure as needed
            }
            do{
                print("Description  \(response)")
                SwiftEventBus.post("refreshCompanions")
                MyVriables.currentComapnion.id = -1
                self.dismiss(animated: false, completion: nil)
                
            }
            catch let error {
                
            }
            
        }
    }
    @IBOutlet weak var updateCompanion: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


}
