//
//  MultiSelectViewController.swift
//  Snapgroup
//
//  Created by snapmac on 13/11/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import ARSLineProgress
import SwiftEventBus
import SwiftHTTP

class MultiSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var isSearching = false
    @IBOutlet weak var titleCatgory: UILabel!
    var filterRequset: FilterGetSelect?
    var filters: FilterGetSelect?
    @IBOutlet weak var tableViewSelect: UITableView!
    var arr: [Bool] = [false,true,false,false,false,false]
    @IBAction func sumbitClick(_ sender: Any) {
        if MyVriables.isCatgory{
            let catgories: [FilterCatgory]? =  self.filters?.categories!.filter({ (company) -> Bool in
                
                if (company.isChecked)! {
                    return true
                }
                return false
            })
            
           // print("Final array is \(catgories!)")
            SwiftEventBus.post("MultiSelect", sender: catgories)
        }else {
            let companies: [FilterCompanies]? =  self.filters?.companies!.filter({ (company) -> Bool in
                
                if (company.isChecked)! {
                    return true
                }
                return false
            })
            
            //print("Final array is \(companies!)")
            SwiftEventBus.post("MultiSelect", sender: companies)
        }
      
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func dismissDialog(_ sender: Any) {
         self.dismiss(animated: false, completion: nil)
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stackViewa: UIStackView!
    @IBOutlet weak var overView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if MyVriables.isCatgory {
            searchBar.isHidden = true
        }else {
            searchBar.isHidden = false
        }
        
        searchBar.returnKeyType = UIReturnKeyType.done
        titleCatgory.text = MyVriables.isCatgory ? "Category" : "Tour Supplier"
        getCatgory(url: ApiRouts.ApiV3+"/groups/filters")
        tableViewSelect.delegate = self
        tableViewSelect.dataSource = self
        searchBar.delegate = self
        overView.layer.borderWidth = 0.2
       // overView
        overView.layer.shadowColor = UIColor.black.cgColor
        overView.layer.shadowOffset = CGSize(width: 0, height: 3)
        overView.layer.borderColor = UIColor.black.cgColor
        overView.layer.cornerRadius = 8.0
        overView.layer.shadowOpacity = 0.6
        overView.layer.shadowRadius = 8
        

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
        if searchBar.text == nil || searchBar.text  == "" {
        self.isSearching = false
           print("Im here after finsh ending")
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
            filterRequset = filters
            tableViewSelect.reloadData()
            
        }
        else{
            
            self.filterRequset?.companies =  self.filters?.companies!.filter({ (company) -> Bool in
               // print("Company name \(String(describing: company.name))")
                if ((((company.name)!).lowercased()).range(of: ((self.searchBar.text)!).lowercased())) != nil {
                   // print("im here and text is \(searchBar.text!)")
                    return true
                }
                return false
            })
            self.tableViewSelect.reloadData()
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectCell", for: indexPath) as! MultiSelectCell
        cell.selectionStyle = .none
        
        cell.tag = indexPath.row
        if MyVriables.isCatgory{
            cell.labelSelect.text = self.filterRequset?.categories?[indexPath.row].title != nil ? (self.filterRequset?.categories?[indexPath.row].title)! : "-"
            if self.filterRequset?.categories?[indexPath.row].isChecked == true {
                cell.imageSelect.image = UIImage(named: "checkboxIOS")
            }else {
                cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
            }
        }else {
            cell.labelSelect.text = self.filterRequset?.companies?[indexPath.row].name != nil ? (self.filterRequset?.companies?[indexPath.row].name)! : "-"
            if self.filterRequset?.companies?[indexPath.row].isChecked == true {
                cell.imageSelect.image = UIImage(named: "checkboxIOS")
            }else {
                cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
            }
        }
        
        cell.switchClick.addTapGestureRecognizer {
            if MyVriables.isCatgory{
                if self.filterRequset?.categories?[indexPath.row].isChecked == true {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                        cell.imageSelect.image = UIImage(named: "checkboxIOS")
                    }) { (success) in
                        self.filterRequset?.categories?[indexPath.row].isChecked = false
                        
                        self.filters?.categories?[indexPath.row].isChecked = false
                        
                        
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                            cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
                        }, completion: nil)
                    }
                }else {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                        cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
                        
                    }) { (success) in
                        self.filterRequset?.categories?[indexPath.row].isChecked = true
                        
                        self.filters?.categories?[indexPath.row].isChecked = true
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                            cell.imageSelect.image = UIImage(named: "checkboxIOS")
                        }, completion: nil)
                    }
                }
            }else {
                if self.filterRequset?.companies?[indexPath.row].isChecked == true {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                        cell.imageSelect.image = UIImage(named: "checkboxIOS")
                    }) { (success) in
                        print("Index path is \(indexPath.row) and index is \((self.filterRequset?.companies?[indexPath.row].index)!)")
                      //  print("Index \(self.filterRequset?.companies?[indexPath.row].index)")
                        self.filterRequset?.companies?[indexPath.row].isChecked = false
                        self.filters?.companies?[(self.filterRequset?.companies?[indexPath.row].index)!].isChecked = false
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                            cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
                        }, completion: nil)
                    }
                }else {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                        cell.imageSelect.image = UIImage(named: "uncheckboxIOS")
                        
                    }) { (success) in
                        self.filterRequset?.companies?[indexPath.row].isChecked = true
                        print("Index path is \(indexPath.row)")
                        print("Index path is \(self.filterRequset?.companies?.count)")
                        print("Index path is \((self.filterRequset?.companies?[indexPath.row].index))")
                        self.filters?.companies?[(self.filterRequset?.companies?[indexPath.row].index)!].isChecked = true
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                            cell.imageSelect.image = UIImage(named: "checkboxIOS")
                        }, completion: nil)
                    }
                }
            }
            
        }
        return cell
    }
    
    func getCatgory(url: String){
        // TODO
        ARSLineProgress.show()
        
        HTTP.GET(url, parameters: []) { response in
            ARSLineProgress.hide()
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return
            }
            do{
                self.filterRequset  = try JSONDecoder().decode(FilterGetSelect.self, from: response.data)
                self.filters = self.filterRequset
                
                DispatchQueue.main.sync {
                    
                    for i in (0..<(self.filters?.companies?.count)!) {
                        //print("Index is i = \(i)")
                        self.filters?.companies?[i].index = i
                        self.filters?.companies?[i].isChecked = false
                        self.filterRequset?.companies?[i].isChecked = false
                        self.filterRequset?.companies?[i].index = i
                    }
                    for i in (0..<(self.filters?.categories?.count)!) {
                        self.filters?.categories?[i].isChecked = false
                        self.filterRequset?.categories?[i].isChecked = false
                        self.filters?.categories?[i].index = i
                        self.filterRequset?.categories?[i].index = i
                    }
                    
                    if (!MyVriables.isCatgory &&  MyVriables.filterComapnies != nil && (MyVriables.filterComapnies?.count)! > 0)  {
                        self.seyValues(isCatgory: false)
                        
                    }else{
                    if (MyVriables.isCatgory &&  MyVriables.filterCatgory != nil && (MyVriables.filterCatgory?.count)! > 0)  {
                        self.seyValues(isCatgory: true)
                        
                    }
                    else{
                        self.tableViewSelect.reloadData()
                    }
                    }
                   
                  
                }
                
            }
            catch let error {
                
            }
            
        }
    }
    func seyValues(isCatgory: Bool){
        if isCatgory{
            for catgory in (MyVriables.filterCatgory)! {
                self.filters?.categories?[catgory.index!].isChecked = true
                self.filterRequset?.categories?[catgory.index!].isChecked = true
            }
            
        }else {
            for company in (MyVriables.filterComapnies)! {
                self.filters?.companies?[company.index!].isChecked = true
                self.filterRequset?.companies?[company.index!].isChecked = true
            }
            
        }
        self.tableViewSelect.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MyVriables.isCatgory{
            return (filterRequset?.categories?.count) != nil ? (filterRequset?.categories?.count)! : 0
        }else {
            return (filterRequset?.companies?.count) != nil ? (filterRequset?.companies?.count)! : 0
        }
        
    }
}
