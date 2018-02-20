//
//  BetterType.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation


struct BetterType {
    
    let id: String
    let type: String
    init?(json: [String: Any]){
        guard let id = json["id"] as? String  ,
        let type = json["type"] as? String  else { return nil }
        self.id = id
        self.type = type
    }
}
