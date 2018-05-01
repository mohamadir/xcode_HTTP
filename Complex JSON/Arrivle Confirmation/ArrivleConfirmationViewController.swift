//
//  ArrivleConfirmationViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 1.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP

class ArrivleConfirmationViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource{

    

    @IBOutlet weak var arriveCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        arriveCollection.delegate = self
        arriveCollection.dataSource = self
        getGroupStations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = arriveCollection.dequeueReusableCell(withReuseIdentifier: "cellConfirmation", for: indexPath) as! ArriceCollectionCell
        if indexPath.row == 0
        {
            cell.view.layer.borderWidth = 1
            cell.view.layer.borderColor = Colors.PrimaryColor.cgColor
          
        }
        else {
            cell.view.layer.borderWidth = 1
            cell.view.layer.borderColor = UIColor.gray.cgColor
           
        }
      
        return cell
    }
    func getGroupStations(){
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "member_id")
        
        print(ApiRouts.Web+"/api/member/\((MyVriables.currentMember?.id!)!)/stations/\((MyVriables.currentGroup?.id!)!)")
        HTTP.GET(ApiRouts.Web+"/api/member/\((MyVriables.currentMember?.id!)!)/stations/\((MyVriables.currentGroup?.id!)!)", parameters: [])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            print(response.description)
            
        }
    }
        

}
