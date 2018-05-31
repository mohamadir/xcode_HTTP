//
//  ContryCodeViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 29.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import CountryPickerView

class ContryCodeViewController: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    @IBOutlet weak var countryPickerView: CountryPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self

        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = true

    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        print(country)
    }


    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
