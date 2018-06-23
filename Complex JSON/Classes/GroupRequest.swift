//
//  GroupRequest.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import UIKit
import SwiftHTTP

struct Main: Codable{
    var data: [TourGroup]?
    var last_page: Int?
    var current_page: Int?
     var total: Int?
    
    // POST METHOD TO GET GROUPS REQUEST
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
                        let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                        groups = groups2.data!
                        DispatchQueue.main.async {
                            completionBlock(groups)
                        }
                    }
                    catch {
                    
                    }
                      
                }
            }.resume()
      
    }
    
    // GET IMAGE REQUEST
    
    func  getGroupImages(id: Int,completionBlock: @escaping ([GroupImage]?) -> Void) -> Void {

        guard let url = URL(string: "\(ApiRouts.Web)/api/groups/\(id)/images")  else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data  else {
                return }
            do{
            let  images = try JSONDecoder().decode([GroupImage].self, from: data)
                 DispatchQueue.main.async {
                        completionBlock(images)
                }
            }
            catch let error {
            }
            }.resume()
        
    }
    
    
    
    func uploadImageToServer(){
  
    }
}




