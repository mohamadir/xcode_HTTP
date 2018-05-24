//
//  ServiceModalViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 29.4.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ServiceModalViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableviewModal: UITableView!
    
    @IBOutlet weak var imageService: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var modelView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do{
        modelView.layer.borderWidth = 2
        modelView.layer.borderColor = UIColor.gray.cgColor
        modelView.layer.shadowColor = UIColor.black.cgColor
        modelView.layer.shadowOpacity = 5
        modelView.layer.shadowOffset = CGSize.zero
        modelView.layer.shadowRadius = 10
        }catch {

        }
        setImageServices()
        tableviewModal.tableFooterView = UIView()
        tableviewModal.delegate = self
        tableviewModal.dataSource = self
        tableviewModal.separatorStyle = .none
        
        tableviewModal.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDistroy(_ sender: Any) {
                dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\((ProviderInfo.currentServiceDay?.count)!)")
        return (ProviderInfo.currentServiceDay?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModalServiceCell", for: indexPath) as! ModalTableViewCell
        cell.selectionStyle = .none
        if ProviderInfo.currentServiceDay?[indexPath.row].name != nil  {
            print("inf if")
            print("\(String(describing: ProviderInfo.currentServiceDay?[indexPath.row].name))")
            cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].name)!
            
        }
        else{
            print("in else")
            if ProviderInfo.currentServiceDay?[indexPath.row].company_name != nil  {
                cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].company_name)!
            }
            else
            {
                if (ProviderInfo.currentServiceDay?[indexPath.row].translations?.count)! > 0
                {
                if ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].name != nil {
            cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].name)!
                }
                else{
                    if ProviderInfo.currentServiceDay?[indexPath.row].company_name != nil {
                         cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].company_name)!
                    }
                    else
                    {
                        if ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].company_name != nil {
                        cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].company_name)!
                        }
                        else
                        {
                            if ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].name != nil {
                                cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].translations?[0].name)!
                            }
                            
                        }
                    }
                    
                }
            }
            else
             {
                 if ProviderInfo.currentServiceDay?[indexPath.row].name != nil {
                     cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].name)!
                }
                else
                {
                    if ProviderInfo.currentServiceDay?[indexPath.row].name != nil {
                         cell.itemServiceLbl.text = (ProviderInfo.currentServiceDay?[indexPath.row].company_name)!
                    }
                    
                }
           
            }
            }
            
        }

        return cell
    }
    func setImageServices(){
       titleLbl.text = (ProviderInfo.currentProviderName)! + " list"
        switch (ProviderInfo.currentProviderName)! {
        case "Hotels":
          imageService.image = UIImage(named: "hotels icon")
        case "Places":
            imageService.image = UIImage(named: "places icon")
        case "Restaurants":
             imageService.image = UIImage(named: "rest")
        case "Tourguides":
            imageService.image = UIImage(named: "TourGuidIcon")
        case "Transport":
           imageService.image = UIImage(named: "transport icon")
        case "Activities":
            imageService.image = UIImage(named: "activities icon")
        default:
             return
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProviderInfo.currentProviderId =  ProviderInfo.currentServiceDay?[indexPath.row].id
     
       self.performSegue(withIdentifier: "showServiceProvider", sender: self)
        
//        weak var pvc = self.presentingViewController as? ItineraryViewController
//        self.dismiss(animated: true) {
//            pvc?.performSegue(withIdentifier: "showServiceProvider", sender: self)
//                print("backosh")
//        }
        
    }
    

    


}
