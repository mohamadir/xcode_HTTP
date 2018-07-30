//
//  CompanyViewController.swift
//  Snapgroup
//
//  Created by snapmac on 6/28/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class CompanyViewController: UIViewController {

    @IBOutlet weak var aboutCompany: UILabel!
    @IBOutlet weak var phoneNuymber: UILabel!
    @IBOutlet weak var busensAdress: UILabel!
    @IBOutlet weak var busensCatgory: UILabel!
    @IBOutlet weak var webAdress: UILabel!
    @IBOutlet weak var comapnyName: UILabel!
    @IBOutlet weak var companyImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        comapnyName.text = MyVriables.currentGroup?.group_leader_company_name != nil ? MyVriables.currentGroup?.group_leader_company_name! : "Company name not defined"
        webAdress.text = MyVriables.currentGroup?.group_leader_company_website != nil ? MyVriables.currentGroup?.group_leader_company_website! : "Website not defined"
        busensAdress.text = MyVriables.currentGroup?.group_leader_company_physical_address != nil ? MyVriables.currentGroup?.group_leader_company_physical_address! : "Adress not defined"
        busensCatgory.text = MyVriables.currentGroup?.group_leader_company_occupation != nil ? MyVriables.currentGroup?.group_leader_company_occupation! : "Company occupation not defined"
        phoneNuymber.text = MyVriables.currentGroup?.group_leader_company_phone != nil ? MyVriables.currentGroup?.group_leader_company_phone! : "Phone number not defined"
        aboutCompany.text = MyVriables.currentGroup?.group_leader_company_about != nil ? MyVriables.currentGroup?.group_leader_company_about! : "there is no informetion "
       // companyImage.image.url
        
        if MyVriables.currentGroup?.group_leader_company_image != nil {
        var urlString = try ApiRouts.Media + (MyVriables.currentGroup?.group_leader_company_image)!
        print("Url string is \(urlString)")
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        var url = URL(string: urlString)
        if url != nil {
            self.companyImage.sd_setImage(with: url!, completed: nil)
        }
        }
        else
        {
            self.companyImage.image = UIImage(named: "group tools title")
        }
    
        
    }



}
