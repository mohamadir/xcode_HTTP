//
//  DestinationData.swift
//  ExpandingTableView
//
//  Created by Thomas Walker on 04/12/2016.
//  Copyright © 2016 CodeBaseCamp. All rights reserved.
//

import Foundation

public class DestinationData {
    public var name: String
    public var price: String
    public var imageName: String
    public var flights: [HotelObj]?
    public var expanded: Bool!
    
    init(name: String, price: String, imageName: String, flights: [HotelObj]?,expanded: Bool) {
        self.name = name
        self.price = price
        self.imageName = imageName
        self.flights = flights
        self.expanded = expanded
    }
}

public class FlightData {
    public var start: String
    public var end: String
    
    init(start: String, end: String) {
        self.start = start
        self.end = end
    }
}

public class PlacesObj  {
    public var name : String
    public var location : String
    public var rating : String
    init(name: String, location: String, rating: String) {
        self.name = name
        self.location = location
          self.rating = rating
    }
}

public class HotelObj  {
    public var name : String
    public var checkin : String
    public var checkout : String
    public var rating : String
    public var id: Int
    
    
    init(checkin: String, checkout: String, name: String, rating:String, id:Int) {
        self.name = name
        self.checkout = checkout
        self.checkin=checkin
        self.rating = rating
        self.id = id
    }
}


