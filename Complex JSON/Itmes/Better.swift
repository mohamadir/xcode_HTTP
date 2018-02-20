//
//  Better.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation

struct Better {
    let betterTypes = [BetterType]
    init?(json: [String: Any]){
        guard let better = json["batter"] as? [[String: Any]] else { return nil }
        let betterTypes = better.map({ BetterType(json: $0)! })
        self.betterTypes = betterTypes
        
    }
}
