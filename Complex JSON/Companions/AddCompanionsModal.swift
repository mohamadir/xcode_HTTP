//
//  AddCompanionsModal.swift
//  Snapgroup
//
//  Created by snapmac on 09/08/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyPickerPopover
import CountryPickerView
import TTGSnackbar
import ARSLineProgress
import SwiftHTTP
import SwiftEventBus


class AddCompanionsModal: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backView: UIView!
    var companions: [CompanionInfo] = []
    @IBOutlet weak var membersList: UICollectionView!
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
        backView.addTapGestureRecognizer {
            self.dismiss(animated: false, completion: nil)

        }
        self.membersList.delegate = self
        self.membersList.dataSource = self
        set18YearValidation()
        self.birthdayBt.setTitle("yyyy-mm-dd", for: .normal)
        self.gender.delegate = self
        self.gender.dataSource = self
        self.firstName.delegate = self
        self.lastName.delegate = self
        
        self.pickerData = ["Male", "Female", "other"]

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func dismissModal(_ sender: Any) {
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
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
      
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companions.count
    }
    override func viewWillAppear(_ animated: Bool) {
        SwiftEventBus.onMainThread(self, name: "companionUpdated") { result in
            print("ime here in remove")
           self.companions[MyVriables.currentIndexCompanion] = MyVriables.currentComapnion
            self.membersList.reloadData()
        }
    }
    
    
    @IBAction func addCompanion(_ sender: Any) {
        if firstName.text! != "" && lastName.text! != "" && self.birthdayBt.titleLabel?.text! != "yyyy-mm-dd" {
            companions.append(CompanionInfo(first_name: firstName.text!, last_name: lastName.text!, group_id: MyVriables.currentGroup?.id!, gender: pickerData[valueSelectedIndex], birth_date: birthdayBt.titleLabel?.text!, id: -1))
            firstName.text = ""
            lastName.text = ""
            self.birthdayBt.setTitle("yyyy-mm-dd", for: .normal)
            membersList.reloadData()
        }
        else
        {
            let snackbar = TTGSnackbar(message: "You must fill all feilds", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = membersList.dequeueReusableCell(withReuseIdentifier: "MemberColectionCell", for: indexPath) as! MemberColectionCell
        cell.fullName.text = companions[indexPath.row].first_name! + " " + companions[indexPath.row].last_name!
        return cell
    }
    @IBAction func saveCompanion(_ sender: Any) {
        if companions.count != 0 {
            saveCompanionFunc()
        }
        else {
            let snackbar = TTGSnackbar(message: "You must Add companions and after save.", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
    }
    func saveCompanionFunc(){
        ARSLineProgress.show()
        print("Url get member is " + ApiRouts.Web+"/api/members/\((MyVriables.currentMember?.id)!)/groups/\((MyVriables.currentGroup?.id)!)")
        var arrayString : String = "["
        var arrayparams : [[String: Any]] = []
        for companion in companions {
            arrayString = arrayString + "{\"first_name\": \"\((companion.first_name)!)\",\"last_name\": \"\((companion.last_name)!)\",\"group_id\": \"\((MyVriables.currentGroup?.id)!)\",\"birth_date\": \"\((companion.birth_date)!)\"},"
        }
       var pSTring = arrayString.dropLast()
        pSTring = pSTring + "]"
        print("array is \(pSTring)")
        let url = ApiRouts.Api+"/members/\((MyVriables.currentMember?.id)!)/companions?string=true"
        HTTP.POST(url, parameters: ["companions" : pSTring]) { response in
            ARSLineProgress.hide()
            print(response.description)
            if let err = response.error {
                print("error: \(err)")
                DispatchQueue.main.sync {
                    var empty: Int = 0
                    if response.statusCode != nil && response.statusCode == 406
                    {
                        print("Respone empty is \(response.text!)")
                        empty = (self.convertToDictionary(text: response.text!)!["empty"]) != nil ? (self.convertToDictionary(text: response.text!)!["empty"])! as! Int : 0
                        print("after=object \(empty)")
                    }
                    // add to table view
                    if empty == 0 {
                    let snackbar = TTGSnackbar(message: "Unfortunately the group is full. Contact the group leader for help.", duration: .long)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                        
                    }
                    else{
                        let snackbar = TTGSnackbar(message: "Unfortunately, you can only add \(empty) people to the group.", duration: .long)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                }
                return //also notify app of failure as needed
            }
            do{
                print("Description  \(response)")
                SwiftEventBus.post("refreshMembers")
                self.dismiss(animated: false, completion: nil)
                
            }
            catch let error {
                
            }
            
        }
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let VerifyAlert = UIAlertController(title: "You can edit or remove companion ", message: nil, preferredStyle: .alert)
        
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: "Default action"), style: .`default`, handler: { _ in
            MyVriables.currentComapnion = self.companions[indexPath.row]
            MyVriables.currentIndexCompanion = indexPath.row
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "editCompanion") as! EditCompanionModal
            self.present(vc, animated: true, completion: nil)
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
            self.companions.remove(at: indexPath.row)
            self.membersList.reloadData()
            
        }))
        self.present(VerifyAlert, animated: true) {
            VerifyAlert.view.superview?.isUserInteractionEnabled = true
        VerifyAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    

    

}
