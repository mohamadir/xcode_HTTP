//
//  RegisterModal.swift
//  Snapgroup
//
//  Created by snapmac on 7/15/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import SwiftHTTP
import SwiftEventBus
import TTGSnackbar
import FBSDKLoginKit
import FBSDKCoreKit

class RegisterModal: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource, FBSDKLoginButtonDelegate {
   
    
    @IBOutlet var facebookLogin: UIButton!
    var currentProfile: MemberProfile?
    var currentMember: CurrentMember?
    var PINCODE: String?
    var contryCodeString : String = ""
    var contryCode : String = ""
    var phoneNumber: String?
    @IBOutlet weak var phoneLbl: UITextField!
    @IBOutlet weak var countryPickerView: CountryPickerView!
    @IBOutlet var modalView: UIView!
    
    @IBAction func sendClick(_ sender: Any) {
        if isValidPhone(phone: contryCodeString+phoneLbl.text!)
        {
            
            print("\(self.contryCodeString)\(self.phoneLbl.text!)")
            self.phoneNumber = contryCodeString+phoneLbl.text!
            if self.contryCodeString == "+972" {
                if self.phoneLbl.text!.count > 4 && self.phoneLbl.text![0...0] == "0" {
                    self.phoneLbl.text!.remove(at: self.phoneLbl.text!.startIndex)
                    self.phoneNumber = "\(self.contryCodeString)\(self.phoneLbl.text!)"
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
                       
                        self.dismiss(animated: false, completion: nil)
                        SwiftEventBus.post("checkMember", sender : "\(self.contryCodeString)\(self.phoneLbl.text!)")

                        
                        
                    }
                    //do things...
                }
                
                
                
            }))
            VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
                print("no")
                self.dismiss(animated: false, completion: nil)
            }))
            self.present(VerifyAlert, animated: true, completion: nil)
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
//        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start { (connection, result, err) in
        
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
    @IBOutlet var loginButton: FBSDKLoginButton!
    @IBOutlet var allView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

       
        facebookLogin.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        self.loginButton.delegate = self
        self.loginButton.readPermissions = ["public_profile","email"]


        modalView.layer.shadowColor = UIColor.gray.cgColor
        modalView.layer.shadowOpacity = 3
        modalView.layer.borderWidth = 2
        modalView.layer.borderColor = UIColor.gray.cgColor
        modalView.layer.shadowOffset = CGSize.zero
        modalView.layer.shadowRadius = 5
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        allView.backgroundColor = UIColor.clear

    }

    @IBAction func dismissFunction(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBack(_ sender: Any) {
        
        
        self.dismiss(animated: true,completion: nil)
        
        
    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        contryCodeString = country.phoneCode
        contryCode = country.code
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
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            
            // Handle cancellations
            
        
            
            
        }
        else {
            // Navigate to other view
            print(result.grantedPermissions)
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
            let _ = request?.start(completionHandler: { (connection, result, error) in
                guard let userInfo = result as? [String: Any] else { return } //handle the error
                print("user indfo \(userInfo)")
                //The url is nested 3 layers deep into the result so it's pretty messy
                if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                    let url = URL(string: imageURL)
//                    self.profileImage.kf.setImage(with: url)
                   // print("Image utl is \(imageURL)")
                    //Download image from imageURL
                }
            })
            
        }
    }
    
    
    
    func btnLoginPressed() {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile"], from: self, handler: { (response:FBSDKLoginManagerLoginResult!, error: NSError!) in
            if(error == nil){
                print("No Error")
                //self.getFacebookUserInfo()
            }
            } as! FBSDKLoginManagerRequestTokenHandler)
    }
    
}

