//
//  DataService.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation

class DataService {
    static  let  shared = DataService()

    private init() {
        
    }
    func getData(completion: (Data) -> Void ){
        guard let path = Bundle.main.path(forResource: "json", ofType: "txt") else { return }
        
        let url = URL( fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            completion(data)
        }catch {
            print(error)
        }
    }
    
    
}
