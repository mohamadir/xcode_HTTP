//
//  CheckListViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//



import UIKit


extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
struct CellData{
    let image : UIImage?
    let message : String?
}
class CheckListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
 
    var data = [CellData]()
    
    var names = ["hosen","mohmd","abd","hosen","mohmd","abd","hosen","mohmd","abd","hosen","mohmd","abd"]

    @IBOutlet weak var tableViewCheckList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        data  = [CellData.init(image : #imageLiteral(resourceName: "snap logo"),message: "String")]
        
        

        tableViewCheckList.delegate = self
        tableViewCheckList.dataSource = self
        tableViewCheckList.separatorStyle = .none
        
        print(self.tableViewCheckList.frame.height)
        
        print(self.tableViewCheckList.frame.height)
       // self.tableViewCheckList
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return names.count
    
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellCheckListItem = tableViewCheckList.dequeueReusableCell(withIdentifier: "cellCheckListItem") as! CheckListItemCell
        cellCheckListItem.itemLbl?.text = names[indexPath.row]
        return cellCheckListItem
        
    }
    

}
