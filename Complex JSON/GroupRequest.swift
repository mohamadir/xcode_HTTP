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
    var current_page: Int?
    
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
        print("====== REQUEST =========")

        guard let url = URL(string: "https://api.snapgroup.co.il/api/groups/\(id)/images")  else { return }
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
        let fileUrl = URL(fileURLWithPath: "/Users/snapmac/Downloads/leader.png")
        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: fileUrl)]) { response in
            
            print(response.description)
            //do things...
        }
    }
}
struct TourGroup: Codable {
    var id: Int?
    var title: String?
    var image: String?
}

struct GroupImage: Codable {
    var id: Int?
    var path: String?
}




