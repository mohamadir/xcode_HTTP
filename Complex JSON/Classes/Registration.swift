//
//  Registration.swift
//  Snapgroup
//
//  Created by snapmac on 7/24/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
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

class Registration: UIViewController{
    
    func facebookRegistration() -> Bool {
        return true
    }
    
    func phoneRegistration(phoneNumber: String,contryCodeString: String) -> Bool {
        if isValidPhone(phone: phoneNumber,contryCode: contryCodeString)
        {
            let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(phoneNumber)", preferredStyle: .alert)
            VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
                let params = ["phone": phoneNumber]
                HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
                    if response.error != nil {
                        print("error \(response.error?.localizedDescription)")
                        return
                    }
                    print ("successed")
                    DispatchQueue.main.sync {
                        self.checkIfMember(textFeild: phoneNumber,type: "phone", facebookMember: nil)
                    }
                }
            }))
            VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
                print("no")
            }))
            present(VerifyAlert, animated: true, completion: nil)
        }
        return true
    }
    
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
                    
                    if (existMember.exist)! == true
                    {
                        if type == "phone"{
                            
                            self.showPinDialog(phone: textFeild,isNewMember: false)
                        }
                        else
                        {
                            print("Im here in facebook exist")
                            //                    self.regstirFacebook(facebookMember: self.facebookMember!, isGdpr:  false)
                        }
                        
                        
                    }else {
                        MyVriables.fromGroup = "true"
                        if type != "phone"{
                            //MyVriables.facebookMember = facebookMember
                        }else {
                            MyVriables.facebookMember = nil
                            self.dismiss(animated: true,completion: nil)
                            MyVriables.phoneNumber = textFeild
                        }
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as? ChatViewController {
                            if let navigator = self.navigationController {
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GdprViewControler") as? GdbrViewController
                        {
                            self.present(vc, animated: true, completion: nil)
                        }
                        //self.performSegue(withIdentifier: "showGdbr", sender: self)
                        
                    }
                }
            }
            catch{
                
            }
            //do things...
        }
        
        
//        print(params)
//        let url = URL(string: strMethod)!
//        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
//        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//        if let json = json {  print(json) }
//        let jsonData = json!.data(using: String.Encoding.utf8.rawValue);
//        var request = URLRequest(url: url)
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        Alamofire.request(request).responseJSON {  (response) in
//            switch response.result {
//            case .success(let JSON2):
//                print("Success with JSON: \(JSON2)")
//                print("RESPONSE \(response.description)")
//
//                break
//
//            case .failure(let error):
//                print("Request failed with error: \(error)")
//                break
//            }
//            }
//            .responseString { response in
//                if (response.result.value!.range(of: "true") != nil)
//                {
//                    if type == "phone"{
//
//                        self.showPinDialog(phone: textFeild,isNewMember: false)
//                    }
//                    else
//                    {
//                        print("Im here in facebook exist")
//                        //                    self.regstirFacebook(facebookMember: self.facebookMember!, isGdpr:  false)
//                    }
//
//
//                }else {
//                    MyVriables.fromGroup = "true"
//                    if type != "phone"{
//                        //MyVriables.facebookMember = facebookMember
//                    }else {
//                        MyVriables.facebookMember = nil
//                        self.dismiss(animated: true,completion: nil)
//                        MyVriables.phoneNumber = textFeild
//                    }
//                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as? ChatViewController {
//                        if let navigator = self.navigationController {
//                            navigator.pushViewController(viewController, animated: true)
//                        }
//                    }
//                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GdprViewControler") as? GdbrViewController
//                    {
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                    //self.performSegue(withIdentifier: "showGdbr", sender: self)
//
//                }
//        }
    }
    public func showPinDialog(phone: String,isNewMember: Bool) {
        
        let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
        print ("pin created")
        PinAlert.addTextField { (textField) in
            textField.placeholder = "1234"
            //textField.shouldChangeText(in: 6, replacementText: "")
        }
        print ("pin created")
        
        var PINCODE: String?
        

            
        PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
            print ("pin 1")
            var params: [String: Any] = [:]
            
            let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
            print ("pin 2")
            
            PINCODE = textField?.text
            print("PIN CODE : \((textField?.text)!)")
            
            if isNewMember == true
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
                let params: [String: Any]
                params = ["code": (textField?.text)!, "phone": MyVriables.phoneNumber!, "gdpr":gdprArr
                ]
            }
            else{
                params = ["code": (textField?.text)!, "phone": phone]
            }
            
            HTTP.POST(ApiRouts.Register, parameters: params) { response in
                //do things...
                if response.error != nil {
                    print(response.error)
                    return
                }
                print(response.description)
                //return response.description
            }
        }))
        print ("pin after ok ")
        
        PinAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCLE", comment: "Default action"), style: .`default`, handler: { action in
            print("no")
            //return ""
        }))
        print ("pin after no ")
        
        present(PinAlert, animated: true, completion: nil)
        print ("pin after present ")
    }
    
    
    func isValidPhone(phone: String,contryCode: String ) -> Bool {
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

}

