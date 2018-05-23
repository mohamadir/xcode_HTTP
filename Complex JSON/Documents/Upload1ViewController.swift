//
//  Upload1ViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 21.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftHTTP
import ARSLineProgress

class Upload1ViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource, IndicatorInfoProvider 
{

 
    var documents: DocumentObject?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        getFilesUpload()
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Document to upload")
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.documents?.required_documents != nil {
             return (self.documents?.required_documents.count)!
        }
        else {
             return 0
        }
     
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uploadCell", for: indexPath) as! UploadItemCell
        cell.selectionStyle = .none
        cell.itemLbl.text = (self.documents?.required_documents[indexPath.row].item)!
        if self.documents?.required_documents[indexPath.row].files.count == 0
        {
            cell.isFileExists.image = UIImage(named: "notice")
            cell.deleteView.isHidden = true
            cell.editView.isHidden = true
            cell.downloadView.isHidden = false
            cell.mimeImageBt.setImage(UIImage(named: "downloadIcon"), for: .normal)
               cell.fileName.text = "Upload"
        }
        else
        {
            
            cell.mimeImageBt.setImage(UIImage(named: "pdfIcon"), for: .normal)
            cell.isFileExists.image = UIImage(named: "done")
            if self.documents?.required_documents[indexPath.row].files[0].filename != nil {
                cell.fileName.text = (self.documents?.required_documents[indexPath.row].files[0].filename)!
            }
            cell.deleteView.isHidden = false
            cell.editView.isHidden = false
            cell.downloadView.isHidden = false
            cell.deleteView.addTapGestureRecognizer {
                self.removeFile(id: (self.documents?.required_documents[indexPath.row].files[0].id)!)
            }
            
        }
        return cell
    }
    func removeFile(id: Int){
        ARSLineProgress.show()
        HTTP.POST("https://api.snapgroup.co.il/api/files/\(id)/group/\((MyVriables.currentGroup?.id)!)", parameters:[])
        { response in
            ARSLineProgress.hide()
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                DispatchQueue.main.sync {
                   self.getFilesUpload()
                    
                }
                
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
   }
    func getFilesUpload() {
        
        //        ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
        //        ProviderInfo.model_type = "activities"
        HTTP.GET("https://api.snapgroup.co.il/api/required_docs/members/\((MyVriables.currentMember?.id)!)/groups/\((MyVriables.currentGroup?.id)!)", parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                self.documents = try JSONDecoder().decode(DocumentObject.self, from: response.data)
                print("The Array is \(self.documents!)")
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }

    
}
