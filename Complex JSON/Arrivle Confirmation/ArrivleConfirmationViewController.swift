//
//  ArrivleConfirmationViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 1.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import TTGSnackbar

class ArrivleConfirmationViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var cancelAriiveConfirmation: UILabel!
    
    @IBOutlet weak var arriveCollection: UICollectionView!
     var stations: [StationModel]?
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelAriiveConfirmation.isHidden = true
        // Do any additional setup after loading the view.
        arriveCollection.delegate = self
        arriveCollection.dataSource = self
        getGroupStations()
        let tap = UITapGestureRecognizer(target: self, action: #selector(ArrivleConfirmationViewController.tapFunction))
        cancelAriiveConfirmation.isUserInteractionEnabled = true
        cancelAriiveConfirmation.addGestureRecognizer(tap)
    }
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Cancel Arrival Confirmation", message: "Are you sure you want to cancel arrival confirmation ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            print("Yay! You brought your towel!")
            self.CancelConfurmation()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("DisAper")
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        MyVriables.IsFromArrival = true
        
     //   dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.stations?.count)
        if self.stations == nil
        {
            return 0
        }
        else{
        return (self.stations?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = arriveCollection.dequeueReusableCell(withReuseIdentifier: "cellConfirmation", for: indexPath) as! ArriceCollectionCell
      
        if (self.stations?.count)! > 0
        {
          if (self.stations?[indexPath.row].location)! == "im_going"
          {
            cell.stationName.text = "self Arrive"
          }
          else{
            cell.stationName.text = (self.stations?[indexPath.row].location)!
            }
        if self.stations?[indexPath.row].my_station  == "true"
        {
            cancelAriiveConfirmation.isHidden = false
            cell.view.layer.borderWidth = 1
            cell.view.layer.borderColor = Colors.PrimaryColor.cgColor
          
        }
        else {
            cell.view.layer.borderWidth = 1
            cell.view.layer.borderColor = UIColor.gray.cgColor
           
        }
        
        }
        
      
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.stations?[indexPath.row].my_station)! == "false"
        {
        SetBusStation(rowNumber: indexPath.row , stationId: (self.stations?[indexPath.row].id)! )
            
        }
        else
        {
            let alert = UIAlertController(title: "Cancel Arrival Confirmation", message: "Are you sure you want to cancel arrival confirmation ?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                print("Yay! You brought your towel!")
                
                self.CancelConfurmation()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    func CancelConfurmation(){
       print(ApiRouts.Api+"/stations?group_id=\((MyVriables.currentGroup?.id!)!)&member_id=\((MyVriables.currentMember?.id!)!)")
        HTTP.DELETE(ApiRouts.Api+"/stations?group_id=\((MyVriables.currentGroup?.id!)!)&member_id=\((MyVriables.currentMember?.id!)!)",  parameters: [])
        { response in
            if let err = response.error {
                print("  error: \(err.localizedDescription)")
                DispatchQueue.main.sync {
                    self.getGroupStations()
                    MyVriables.shouldRefreshBusStation = true
                    self.cancelAriiveConfirmation.isHidden = true
                    let snackbar = TTGSnackbar(message: "You canceld arrival confirmation", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                return //also notify app of failure as needed
            }
            do
            {
                //self.stations  = try JSONDecoder().decode([StationModel].self, from: response.data)
                DispatchQueue.main.sync {
                    self.getGroupStations()
                    MyVriables.shouldRefreshBusStation = true
                    
                }
            }
            catch {
                
            }
            
            print(response.description)
            
        }
    }
    func SetBusStation(rowNumber: Int , stationId: Int){
        print("station id is \(stationId) and group id is \((MyVriables.currentGroup?.id!)! ) and member id is \((MyVriables.currentMember?.id!)!)")
        HTTP.POST(ApiRouts.Api+"/stations/member",  parameters: ["station_id": stationId , "group_id" :(MyVriables.currentGroup?.id!)! , "member_id" : (MyVriables.currentMember?.id!)!])
        { response in
            if let err = response.error {
                print("  error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do
            {
                //self.stations  = try JSONDecoder().decode([StationModel].self, from: response.data)
                DispatchQueue.main.sync {
                    self.getGroupStations()
                    MyVriables.shouldRefreshBusStation = true
                    var station: String = (self.stations?[rowNumber].location!)!
                    var snack_text: String = ""
                    if station != "im_going" {
                        snack_text = "You choose \((self.stations?[rowNumber].location!)!) station  !"
                    }else {
                        snack_text = "You chose to go alone"
                    }
                    
                    let snackbar = TTGSnackbar(message: snack_text, duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
            }
            catch {
                
            }
            
            print(response.description)
            
        }
    }
    //shouldRefreshBusStation = true
    func getGroupStations(){
    
        print(ApiRouts.Api+"/member/\((MyVriables.currentMember?.id!)!)/stations/\((MyVriables.currentGroup?.id!)!)")
        HTTP.GET(ApiRouts.Api+"/member/\((MyVriables.currentMember?.id!)!)/stations/\((MyVriables.currentGroup?.id!)!)", parameters: [])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do
            {
               self.stations  = try JSONDecoder().decode([StationModel].self, from: response.data)
                DispatchQueue.main.sync {
                        self.arriveCollection.reloadData()
                    
                }
            }
            catch {
                
            }
            
            print(response.description)
            
        }
        
        ////   items.add(new UpdateCheck(response.getJSONObject(z).getString("location").toString(),
//        response.getJSONObject(z).getString("my_station").toString(),
//        response.getJSONObject(z).getString("id").toString(), -1));
    }
        

}
