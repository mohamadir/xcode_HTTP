//
//  ExpandingTVC.swift
//  ExpandingTableView
//
//  Created by Thomas Walker on 04/12/2016.
//  Copyright © 2016 CodeBaseCamp. All rights reserved.
//

import Foundation
import UIKit
import SwiftHTTP
class ExpandingTVC : UITableViewController {
    
    var destinationData: [DestinationData?]?
    var servicess: ServicesModel?
    var data: [DestinationData?] = []
    override func viewDidLoad() {
        
       getData()
        
        //self.automaticallyAdjustsScrollViewInsets = false;
        //tableView.estimatedRowHeight = 142;
        //self.tableView.setNeedsLayout()
        //self.tableView.layoutIfNeeded()
        //tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    ///name: String, checkin: String, rating: String, checkout: String
    
    private func getData()
    {
        
         //getGroupChecklist()
        
        HTTP.GET(ApiRouts.Web+"/api/groups/\((MyVriables.currentGroup?.id!)!)/services", parameters: ["hello": "world", "param2": "value2"])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            
            do{
                
                
                self.servicess  = try JSONDecoder().decode(ServicesModel.self, from: response.data)
                //anArray.append("This String")
                print(ApiRouts.Web+"/api/groups/\((MyVriables.currentGroup?.id!)!)/services")
                if (self.servicess?.hotels?.count)! > 0
                {
                    var hotelsObject: [HotelObj?] = []
                    hotelsObject.append(HotelObj(checkin: "checkin", checkout: "checkout", name: "hotel name", rating:"Ratings", id: 0 ))
                    for hotel in (self.servicess?.hotels)! {
                         hotelsObject.append(HotelObj(checkin: "\((hotel.first_day)!)", checkout: "\(((hotel.last_day)!)+1)", name:
                            ( hotel.name != nil ? hotel.name : hotel.translations?[0].name)!, rating:"", id: 0  ))
                    }
                    let london = DestinationData(name: "Hotels", price: "£500", imageName: "hotels icon", flights: hotelsObject as! [HotelObj], expanded: false)
                    self.data.append(london)
                }
                if (self.servicess?.places?.count)! > 0
                {
                    var placesObject: [HotelObj?] = []
                    placesObject.append(HotelObj(checkin: "place name", checkout: "Location", name: "", rating:"Ratings" , id: 0 ))
                    for place in (self.servicess?.places)! {
                        placesObject.append(HotelObj(checkin:  (place.name != nil ? place.name : place.translations?[0].name)!
                            , checkout: (place.city != nil ? place.city : place.translations?[0].city)!, name:
                            "", rating:"5-10" , id: 0 ))
                    }
                    let london = DestinationData(name: "Places", price: "£500", imageName: "places icon", flights: placesObject as! [HotelObj], expanded: false)
                    self.data.append(london)
                }
                if (self.servicess?.restaurants?.count)! > 0
                {
                    var restaurantsObject: [HotelObj?] = []
                    restaurantsObject.append(HotelObj(checkin: "resturant", checkout: "", name: "", rating:"Ratings", id: 0  ))
                    for resturant in (self.servicess?.restaurants)! {
                        restaurantsObject.append(HotelObj(checkin:  (resturant.name != nil ? resturant.name : resturant.translations?[0].name)!
                            , checkout: "", name:
                            "", rating:"5-10" , id: 0 ))
                    }
                    let london = DestinationData(name: "Restaurants", price: "£500", imageName: "rest", flights: restaurantsObject as! [HotelObj], expanded: false)
                    self.data.append(london)
                }
                if (self.servicess?.tourguides?.count)! > 0
                {
                    
                    var tourguideies: [HotelObj?] = []
                    tourguideies.append(HotelObj(checkin: "Full name", checkout: "langouhgs", name: "Age", rating:"Ratings", id: 0  ))
                    for transport in (self.servicess?.tourguides)! {
                        tourguideies.append(HotelObj(checkin: "\((transport.translations?[0].first_name)!) \((transport.translations?[0].last_name)!)"
                            , checkout: transport.translations?[0].languages != nil ? (transport.translations?[0].languages)! : "",
                              name:transport.age != nil ? "\((transport.age)!)" : "not found", rating:"", id: 0 ))
                    }
                    let london = DestinationData(name: "Tourguides", price: "£500", imageName: "TourGuidIcon", flights: tourguideies as! [HotelObj], expanded: false)
                    self.data.append(london)
                }
                if (self.servicess?.transports?.count)! > 0
                {
                    var transportObject: [HotelObj?] = []
                    transportObject.append(HotelObj(checkin: "company", checkout: "langouhgs", name: "", rating:"phone" , id: 0 ))
                    for transport in (self.servicess?.transports)! {
                        transportObject.append(HotelObj(checkin:  (transport.company_name != nil ? transport.company_name : transport.translations?[0].company_name)!
                            , checkout: "", name:
                            "", rating:(transport.phone != nil ? transport.phone! : ""), id: 0))
                    }
                    let london = DestinationData(name: "Transport", price: "£500", imageName: "transport icon", flights: transportObject as! [HotelObj], expanded: false)
                    self.data.append(london)
                }
                if (self.servicess?.activities?.count)! > 0
                {
                    var placesObject: [HotelObj?] = []
                    placesObject.append(HotelObj(checkin: "place name", checkout: "Location", name: "", rating:"Ratings" , id: 0 ))
                    for activitie in (self.servicess?.activities)! {
                        placesObject.append(HotelObj(checkin:  (activitie.name != nil ? activitie.name : activitie.translations?[0].name)!
                            , checkout: (activitie.city != nil ? activitie.city : activitie.translations?[0].city)!, name:
                            "", rating:"5-10", id: 0  ))
                    }
                    let london = DestinationData(name: "Activities", price: "£500", imageName: "activities icon", flights: placesObject as! [HotelObj], expanded: false)
                    self.data.append(london)
                    
                }
                print(self.data.count)
                self.destinationData = self.data
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                }
            
            
                
            }
            catch let error {
                print(error)
            }
            
        }
       
       
    }
    
    /*  Number of Rows  */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("data count is \(data.count)")
        if let data = destinationData {
            return data.count
        } else {
            return 0
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.separatorStyle = .none
//        if let rowData = destinationData?[indexPath.row] {
//            return 60
//        } else {
//            return 58
//        }
//
//    }
    

   
    /*  Create Cells    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Row is DefaultCell
        if let rowData = destinationData?[indexPath.row] {
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! DefaultCell
            defaultCell.DestinationLabel.text = rowData.name
            defaultCell.imageService.image = UIImage(named: rowData.imageName)
            tableView.separatorStyle = .none
            return defaultCell
        }
        // Row is ExpansionCell
        else {
            if let rowData = destinationData?[getParentCellIndex(expansionIndex: indexPath.row)] {
                //  Create an ExpansionCell
                let expansionCell = tableView.dequeueReusableCell(withIdentifier: "ExpansionCell", for: indexPath) as! ExpansionCell
                    
                //  Get the index of the parent Cell (containing the data)
                let parentCellIndex = getParentCellIndex(expansionIndex: indexPath.row)
                    
                //  Get the index of the flight data (e.g. if there are multiple ExpansionCells
                let flightIndex = indexPath.row - parentCellIndex - 1
                    
                //  Set the cell's data
               
                    expansionCell.name.text = rowData.flights?[flightIndex].checkin
                    expansionCell.location.text = rowData.flights?[flightIndex].checkout
                    expansionCell.phone.text = rowData.flights?[flightIndex].name
                    expansionCell.email.text = rowData.flights?[flightIndex].rating
                    expansionCell.selectionStyle = .none
                
                
                return expansionCell
            }
        }
        tableView.separatorStyle = .none
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
   
        print("index path is \(indexPath.row) and index \(indexPath.count)")
        if let data = destinationData?[indexPath.row] {
            
            
            // If user clicked last cell, do not try to access cell+1 (out of range)
            if(indexPath.row + 1 >= (destinationData?.count)!) {
                expandCell(tableView: tableView, index: indexPath.row)
                
            }
            else {
                // If next cell is not nil, then cell is not expanded
                if(destinationData?[indexPath.row+1] != nil) {
                   
                    expandCell(tableView: tableView, index: indexPath.row)
                // Close Cell (remove ExpansionCells)
                } else {
                  
                    contractCell(tableView: tableView, index: indexPath.row)

                }
            }
        }
    }
    
    /*  Expand cell at given index  */
    private func expandCell(tableView: UITableView, index: Int) {
        // Expand Cell (add ExpansionCells
        print("destination size is \((destinationData?.count)!)")
        if let flights = destinationData?[index]?.flights {
            for i in 1...flights.count {
                destinationData?.insert(nil, at: index + i)
                tableView.insertRows(at: [NSIndexPath(row: index + i, section: 0) as IndexPath] , with: .top)
            }
            
            
            
        }
    }
 
    
    
    /*  Contract cell at given index    */
    private func contractCell(tableView: UITableView, index: Int) {
        print("im in heree index \(index)")
        if let flights = destinationData?[index]?.flights {
            for i in 1...flights.count {
                destinationData?.remove(at: index+1)
                tableView.deleteRows(at: [NSIndexPath(row: index+1, section: 0) as IndexPath], with: .top)

            }
        }
    }
    
    /*  Get parent cell index for selected ExpansionCell  */
    private func getParentCellIndex(expansionIndex: Int) -> Int {
        print("im here hereeeee \(expansionIndex)")
        var selectedCell: DestinationData?
        var selectedCellIndex = expansionIndex
        
        while(selectedCell == nil && selectedCellIndex >= 0) {
            selectedCellIndex -= 1
            selectedCell = destinationData?[selectedCellIndex]
        }
        
        return selectedCellIndex
    }
    func getGroupChecklist(){

        HTTP.GET(ApiRouts.Web+"/api/groups/\((MyVriables.currentGroup?.id!)!)/services", parameters: ["hello": "world", "param2": "value2"])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            
            do{
            
                self.servicess  = try JSONDecoder().decode(ServicesModel.self, from: response.data)
                print(self.servicess)
               
            }
            catch let error {
                print(error)
            }
            
        }
        
        
    }
}











