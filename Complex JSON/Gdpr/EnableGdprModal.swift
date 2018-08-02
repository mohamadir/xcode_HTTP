//
//  EnableGdprModal.swift
//  Snapgroup
//
//  Created by snapmac on 6/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import TTGSnackbar
import SwiftEventBus
import SwiftHTTP
class EnableGdprModal: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        switchGdpr.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleSwitch.text = (MyVriables.enableGdpr?.title)!
        descrptionSwitch.text = (MyVriables.enableGdpr?.descrption)!
        firstTitle.text = (MyVriables.enableGdpr?.image)!
    }

    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var switchGdpr: UISwitch!
    @IBOutlet weak var descrptionSwitch: UILabel!
    @IBOutlet weak var titleSwitch: UILabel!

    @IBAction func onContinue(_ sender: Any) {
        if switchGdpr.isOn == true {
            setCheck(isChecked: true, chekAll: false, postion: -1)
        } else {
            let snackbar = TTGSnackbar(message: "please check the switch to true to continue", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }
    @IBAction func onDismiss(_ sender: Any) {
        dismiss(animated: true,completion: nil)
    }
    func setCheck(isChecked : Bool, chekAll : Bool, postion : Int){
        var params: [String: Any] = ["" : true]
        params = [(MyVriables.enableGdpr?.parmter)!: isChecked]
        HTTP.PUT("\(ApiRouts.Api)/members/\((MyVriables.currentMember?.id)!)/gdpr", parameters: params) {
            response in
            if response.error != nil {
                return
            }
            do {
                let  gdprUpdate : GdprUpdate = try JSONDecoder().decode(GdprUpdate.self, from: response.data)
                MyVriables.currentMember?.gdpr = GdprStruct(profile_details: (gdprUpdate.gdpr?.profile_details)!, phone_number: (gdprUpdate.gdpr?.phone_number)!, groups_relations: (gdprUpdate.gdpr?.groups_relations)!, chat_messaging: (gdprUpdate.gdpr?.chat_messaging)!, pairing: (gdprUpdate.gdpr?.pairing)!, real_time_location: (gdprUpdate.gdpr?.real_time_location)!, files_upload: (gdprUpdate.gdpr?.files_upload)!, push_notifications: (gdprUpdate.gdpr?.push_notifications)!, rating_reviews: (gdprUpdate.gdpr?.rating_reviews)!, group_details: (gdprUpdate.gdpr?.profile_details)!, billing_payments : true, checkAllSwitch: true)
                self.dismiss(animated: true, completion: nil)
                SwiftEventBus.post("refresh-\((MyVriables.enableGdpr?.parmter)!)")
                

            }
            catch {
                
            }
            
        }
    }
    
}
