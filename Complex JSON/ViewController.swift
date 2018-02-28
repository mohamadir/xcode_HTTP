//
//  ViewController.swift
//  Complex JSON
//
//  Created by snapmac on 2/20/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Crashlytics
import SwiftHTTP
import SDWebImage
import MRCountryPicker


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



struct MyVriables {
    static var currentGroup: TourGroup?
    
    
}




class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,  MRCountryPickerDelegate{
    
    // header views
    
    @IBOutlet weak var chatHeaderStackView: UIStackView!
    @IBOutlet weak var phoneNumberStackView: UIStackView!
    
    var PINCODE: String?
    var phoneNumber: String?
    
    @IBOutlet weak var countryPicker: MRCountryPicker!
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var chatImageView: UIImageView!
    
    
    @IBOutlet weak var countryPrefLable: UILabel!
    var myGrous: [TourGroup] = []
    var currentGroup: TourGroup?
    @IBOutlet weak var tableView: UITableView!
    let cellSpacingHeight: CGFloat = 5
    var whatIsCurrent: Int  = 0
    var hasLoadMore: Bool = true
    var refresher: UIRefreshControl!
    var dbRererence: DatabaseReference?
    var page: Int = 1
    var groupImages: [GroupImage] = []
    var flagImage: UIImage?
    @IBOutlet weak var phoneNumberFeild: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.flagImageView.image = flag
        self.countryPrefLable.text = phoneCode
        self.countryPicker.isHidden = true
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        phoneNumberFeild.keyboardType = .numberPad
        setCountryPicker()
        setChatTap()
        DispatchQueue.main.async {
            self.getSwiftGroups(){ (output) in
//
//                self.myGrous = output!
//
//                print(self.myGrous)
//
//                    self.tableView.reloadData()
                
            }
        }
        
        UserDefaults.standard.set("titelooooooooooosh", forKey: "title")
      //  setUpNavigationItmes()
        let fred = Person(name: "fred", age: 32, dog: Dog(name: "Spot", breed: .beagle))
        let mohamd = Person(name: "mohamd", age: 32, dog: Dog(name: "Spot", breed: .beagle))
        let abd = Person(name: "abd", age: 32, dog: Dog(name: "Spot", breed: .beagle))
        let encoder = JSONEncoder()
        self.setupNavigationBarItmes()
        let data  = try! encoder.encode(fred)
        print(data)
        let person2: Person
        let decoder = JSONDecoder()
        person2 = try! decoder.decode(Person.self , from: data)
        print(person2.age)
        
        
        dbRererence = Database.database().reference()
        dbRererence?.child("name").childByAutoId().setValue("Yarsh")
        dbRererence?.child("name").childByAutoId().setValue("Rabil")
        dbRererence?.child("name").childByAutoId().setValue("Mohamed")

        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        
        
        let group = Group(title: "groupy", people: [fred,mohamd,abd])
        let groupData = try! encoder.encode(group)
        
        let groupy = try! decoder.decode(Group.self, from: groupData)
        
      //  print(groupy)
        
        
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
        
//        let groupRequest = Main()
//        groupRequest.getGroups(){ (output) in
//            self.myGrous = output!
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//
//            print("&&&&&& \(self.myGrous[0].image)")
//        }
//
//
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setChatTap(){
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("chatTapped"))
        chatImageView.isUserInteractionEnabled = true
        chatImageView.addGestureRecognizer(singleTap)
    }
    
  @objc  func chatTapped(){
    print("chat tapped")
    
    performSegue(withIdentifier: "showChat", sender: self)

    }
    
    
   
    
    @objc func refreshData(){
        print("refresh is loading")
        self.page = 1
        self.myGrous = []
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.getSwiftGroups(){ (output) in
            }
        }
        
    }
    
    @IBAction func onPickerTapped(_ sender: Any) {
        self.countryPicker.isHidden = false

    }
    
    
   
    
    
    func setCountryPicker(){
        countryPicker.isHidden = true
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            countryPicker.setLocale(countryCode)
        }
          countryPicker.setCountry(Locale.current.regionCode!)
       // print(Locale.current.regionCode)

        
//        // set country by its code
//        countryPicker.setCountry("SI")
//
//        // optionally set custom locale; defaults to system's locale
//        countryPicker.setLocale("sl_SI")
        
        // set country by its name
  
    //    countryPicker.setCountryByName("Canada")
    }
    
    //
   func setUpNavigationItmes(){
//        let filterButton = UIButton(type: .system)
//        filterButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
//        self.view.addSubview(filterButton)
//        filterButton.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: filterButton)
    
    }
    
    @IBAction func sendClick(_ sender: Any) {
        
        print("\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)")
        self.phoneNumber = "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"
        
        let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)", preferredStyle: .alert)
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            let params = ["phone": self.phoneNumber]
            
            HTTP.POST("https://api.snapgroup.co.il/api/getregistercode", parameters: params) { response in
                
                if response.statusCode == 201 {
                    print ("successed")
                    
                    let PinAlert = UIAlertController(title: "Please enter PIN code wer'e sent you", message: "Pin code", preferredStyle: .alert)
                    
                    PinAlert.addTextField { (textField) in
                        textField.placeholder = "1234"
                        
                    }
                    PinAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak PinAlert] (_) in
                        let textField = PinAlert?.textFields![0] // Force unwrapping because we know it exists.
                        self.PINCODE = textField?.text
                        print("PIN CODE : \((textField?.text)!)")
                        
                        let params = ["code": (textField?.text)!, "phone": "\(self.countryPrefLable.text!)\(self.phoneNumberFeild.text!)"]
                        HTTP.POST("https://api.snapgroup.co.il/api/register", parameters: params) { response in
                            //do things...
                            print(response.description)
                        }
                        
                        
                        
                        
                    }))
                    PinAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCLE", comment: "Default action"), style: .`default`, handler: { _ in
                        print("no")
                        
                    }))
                    self.present(PinAlert, animated: true, completion: nil)
                    

                }
                
                //do things...
            }
            
            
            // pin code dialog
            
            
            // replace header
            
//            print("yes")
//           self.phoneNumberStackView.isHidden = true
//           self.chatHeaderStackView.isHidden = false
            
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")

            
            
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    
    // get groups reqeust: by page
    
    func getSwiftGroups(completionBlock: @escaping ([TourGroup]?) -> Void) -> Void {
        print("request PAGE = \(self.page)")
        let params = ["page": self.page]
        var groups: [TourGroup]?
        HTTP.POST("https://api.snapgroup.co.il/api/getallgroups", parameters: params) { response in
            //do things...
          //  print(response.description)
            let data = response.data
            do {
                let  groups2 = try JSONDecoder().decode(Main.self, from: data)
                
                groups = groups2.data!
                if groups?.count == 0 {
                    self.hasLoadMore = false
                    return
                }

                DispatchQueue.main.sync {
                    for group in groups! {
                        self.myGrous.append(group)
                    }
                 //   self.myGrous = groups!
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    completionBlock(groups)
                }
              //  print(self.myGrous.count)
            }
            catch {
                
            }
            
        }
    }
    
    // not needed
    @objc func onClick(sender: UIButton!){
        print("clicked")
        performSegue(withIdentifier: "showModal", sender: self)

        
        
    }
    
    
    func setupNavigationBarItmes(){
//        navigationController?.navigationBar.barTintColor = UIColor.white
//        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "new logo"))
//        titleImageView.contentMode = .scaleAspectFit
//        navigationItem.titleView = titleImageView
        
    }
   
    
    // not needed
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? GroupViewController {
            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
        }
        
        if let destination = segue.destination as? HomeViewController {
            print("home destination")
            destination.singleGroup = self.myGrous[(tableView.indexPathForSelectedRow?.row)!]
        }
    }


    
    /////////////////////////////// Tableview initialize ///////////////////////////
    
    
    // pagination loadmore : check last item
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastitem =  self.myGrous.count - 1
        if indexPath.row == lastitem && hasLoadMore == true{
            
            DispatchQueue.main.async {
                self.getSwiftGroups(){ (output) in
                    
                }
            }
        }
    }
    
    // tableview: tableview count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("hi \(myGrous.count)")
        return self.myGrous.count
    }
    
    
    // tableview: return the cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        let urlString = "https://api.snapgroup.co.il" + (self.myGrous[indexPath.row].image)!
        var url = URL(string: urlString)
        cell.selectionStyle = .none
        if url == nil {
        }
        else
        {
            cell.imageosh.downloadedFrom(url: url! , contentMode: .scaleToFill)
        }
        
        cell.groupLabel.text = self.myGrous[indexPath.row].title
        
        
        
        return cell
        
    }
    // tableview: selected row
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "groupDetailsBar", sender: self)
        MyVriables.currentGroup = self.myGrous[indexPath.row]
        
    }
    
    // height for each section
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.cellSpacingHeight
    }
    


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

