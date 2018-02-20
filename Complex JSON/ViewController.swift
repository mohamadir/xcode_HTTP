//
//  ViewController.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

struct Group: Codable {
    var title: String
    var people: [Person]
    
    init(title: String, people: [Person])
    {
        self.title = title
        self.people = people
    }
    
    
}

struct Person: Codable {
    var name: String
    var age: Int
    var dog: Dog
}

struct Dog: Codable {
    var name: String
    var breed: Breed
    
    
    enum Breed: String, Codable {
        case collie = "Collie"
        case beagle = "Beagle"
        case gret = "Gret"
    }
}


struct Book: Codable {
    var title: String
    var author: String
    var pageCount: Int
    
    // Provide explicit string values for properties names that don't match JSON keys.
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case pageCount = "number_of_pages"
    }
}



struct Main: Codable{
    var data: [TourGroup]?
    var current_page: Int?
}
struct TourGroup: Codable {
    var id: Int?
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
    
}





class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let fred = Person(name: "fred", age: 32, dog: Dog(name: "Spot", breed: .beagle))
        let mohamd = Person(name: "mohamd", age: 32, dog: Dog(name: "Spot", breed: .beagle))
        let abd = Person(name: "abd", age: 32, dog: Dog(name: "Spot", breed: .beagle))

        let encoder = JSONEncoder()
        
        let data  = try! encoder.encode(fred)
        print(data)
        let person2: Person
        let decoder = JSONDecoder()
        person2 = try! decoder.decode(Person.self , from: data)
        print(person2.age)
        
        
        let group = Group(title: "groupy", people: [fred,mohamd,abd])
        let groupData = try! encoder.encode(group)
        
        let groupy = try! decoder.decode(Group.self, from: groupData)
        
        print(groupy)
        
        
        let bookJsonText =
        """
        {
          "title": "War of the Worlds",
          "author": "H. G. Wells",
          "publication_year": 2012,
          "number_of_pages": 240
        }
        """
        let bookData = bookJsonText.data(using: .utf8)!
        let book = try! decoder.decode(Book.self, from: bookData)
        
        print(book)
        getGroups()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    
    func getGroups(){
        guard let url = URL(string: "https://api.snapgroup.co.il/api/getallgroups") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: [], options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response , error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    print("*****************************")
                    let groups = try JSONDecoder().decode(Main.self, from: data)

                    
                    
                    print(groups)
                    
                }
                catch {
                    print(error)
                }
                
                
            }
            
            
            }.resume()
    }


}

