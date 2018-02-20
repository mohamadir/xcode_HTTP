//
//  GroupRequest.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation

struct Main: Codable{
    var data: [TourGroup]?
    var current_page: Int?
    
    
     func  getGroups(completionBlock: @escaping ([TourGroup]?) -> Void) -> Void {
        
            guard let url = URL(string: "https://api.snapgroup.co.il/api/getallgroups") else { return  }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Content-Type", forHTTPHeaderField: "application/json")
                var groups: [TourGroup]?

                guard let httpBody = try? JSONSerialization.data(withJSONObject: [], options: []) else { return }
                    request.httpBody = httpBody
                    let session = URLSession.shared
                    session.dataTask(with: request) {(data, response , error) in
                    if let response = response {
                   //     print(response)
                    }

                    if let data = data {
                    do {
                        print("*****************************")
                        let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                        groups = groups2.data!
                        completionBlock(groups)
                       // print(groups[0].id)
                    }
                    catch {
                     //   print(error)
                        }
                      

                        }
                    }.resume()
      
    }
}
struct TourGroup: Codable {
    var id: Int?
    var title: String?
    //
    //    enum CodingKeys: String, CodingKey {
    //        case id
    //        case title
    //    }
    
}



