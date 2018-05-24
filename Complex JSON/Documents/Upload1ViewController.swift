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

class Upload1ViewController: UIViewController ,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UITableViewDataSource, IndicatorInfoProvider
{

 
    var indexMedia : Int = 0
    @IBOutlet weak var viewNoDocs: UIView!
    var documents: DocumentObject?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        viewNoDocs.isHidden = true
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
        cell.tag = indexPath.row
        cell.itemLbl.text = (self.documents?.required_documents[indexPath.row].item)!
        if self.documents?.required_documents[indexPath.row].files.count == 0
        {
            cell.isFileExists.image = UIImage(named: "notice")
            cell.deleteView.isHidden = true
            cell.editView.isHidden = true
            cell.downloadView.isHidden = false
            cell.mimeImageBt.image = UIImage(named: "downloadIcon")
            cell.fileName.text = "Upload"
        }
        else
        {
            cell.mimeImageBt.image = UIImage(named: "pdfIcon")
            cell.isFileExists.image = UIImage(named: "done")
            if self.documents?.required_documents[indexPath.row].files[0].filename != nil {
                cell.fileName.text = (self.documents?.required_documents[indexPath.row].files[0].filename)!
            }
            cell.deleteView.isHidden = false
            cell.editView.isHidden = true
            cell.downloadView.isHidden = false
            cell.deleteView.addTapGestureRecognizer {
                self.removeFile(id: (self.documents?.required_documents[indexPath.row].files[0].id)!)
            }
            
        }
        cell.downloadView.addTapGestureRecognizer {
            self.indexMedia = indexPath.row
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
            //self.uploadFile(id: (self.documents?.required_documents[indexPath.row].id)!)
        }
        cell.editView.addTapGestureRecognizer {
//            let controller = UIImagePickerController()
//            controller.delegate = self
//            controller.sourceType = .photoLibrary
//            self.present(controller, animated: true, completion: nil)
           // self.uploadFile(id: (self.documents?.required_documents[indexPath.row].id)!)
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
  
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
        dismiss(animated: true, completion: nil)
        ARSLineProgress.hide()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: URL
        if #available(iOS 11.0, *) {
            image = info[UIImagePickerControllerImageURL] as! URL
        } else {
            // Fallback on earlier versions
            image = info[UIImagePickerControllerReferenceURL] as! URL
            
        }
        var urlString: String = ApiRouts.Web + "/api/upload/\((MyVriables.currentMember?.id!)!)?upload_type=group&group_id=\((MyVriables.currentGroup?.id)!)&file_type=\((self.documents?.required_documents[indexMedia].item)!)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        ARSLineProgress.show()
        print("image ref: \(image)" )
        print("print INFO : \(info)")
        print("URL IS =" + ApiRouts.Web + "/api/upload/\((MyVriables.currentMember?.id!)!)?upload_type=group&group_id=\((MyVriables.currentGroup?.id)!)&file_type=\((self.documents?.required_documents[indexMedia].item)!)")
        dismiss(animated: true, completion: nil)
        HTTP.POST(urlString, parameters: ["file": Upload(fileUrl: image.absoluteURL)]) { response in
            print("response is : \(response.data)")
            ARSLineProgress.hide()
            let data = response.data
            do {
                if response.error != nil {
                    print("response is : ERROR \(response.error)")
                    return
                }
                print("response is :")
                print(response.description)
               
            }catch let error {
                print(error)
            }
            
            self.getFilesUpload()
            print(response.data)
            print(response.data.description)
            if response.error != nil {
                print(response.error)
            }
            //do things...
            
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
                if (self.documents?.required_documents.count)! == 0 {
                    DispatchQueue.main.sync {
                        self.viewNoDocs.isHidden = false
                    }
                }
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
