//
//  ReviewsViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 14.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var provdierName: UILabel!
    @IBOutlet weak var genralRatings: UILabel!
    @IBOutlet weak var reviewsTableview: UITableView!
    var ratingsArray: [RatingModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provdierName.text =  ProviderInfo.nameProvider
        if ProviderInfo.ratings != nil {
        genralRatings.text = ProviderInfo.ratings!
        }
        reviewsTableview.delegate = self
        reviewsTableview.dataSource = self
         reviewsTableview.separatorStyle = .none
        getRatings()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBack(_ sender: Any) {
           navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ratingsArray != nil {
        return  (self.ratingsArray?.count)!
        }else
        {return 0}
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! AllReviewsTableViewCell
        
        cell.selectionStyle = .none
        if self.ratingsArray != nil {
            cell.nameLbl.text = "\((self.ratingsArray?[indexPath.row].first_name)!) \((self.ratingsArray?[indexPath.row].last_name)!)"
            cell.commentLbl.text = "\((self.ratingsArray?[indexPath.row].review)!) "
            cell.ratingNumber.text = "\((self.ratingsArray?[indexPath.row].rating)!) out of 10"
            
            
            if self.ratingsArray?[indexPath.row].image_path != nil
            {
                var urlString: String = try ApiRouts.Web + (self.ratingsArray?[indexPath.row].image_path)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                if let url = URL(string: urlString) {
                    cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default user"), completed: nil)
                    
                }
            }
        }
        
        return cell
        
    }
    func getRatings() {
        HTTP.GET(ProviderInfo.urlRatings!, parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                self.ratingsArray = try JSONDecoder().decode([RatingModel].self, from: response.data)
                print("The Array is \(self.ratingsArray!)")
                DispatchQueue.main.sync {
                    self.reviewsTableview.reloadData()
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }
    
}
