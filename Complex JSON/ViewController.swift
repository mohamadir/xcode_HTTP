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








class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myGrous: [TourGroup] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        let groupRequest = Main()
        groupRequest.getGroups(){ (output) in
            self.myGrous = output!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print("&&&&&& \(self.myGrous.count)")
        }
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hi \(myGrous.count)")
        return self.myGrous.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.myGrous[indexPath.row].title
    
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    
   


}

