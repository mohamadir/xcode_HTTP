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
import Alamofire
import SwiftEventBus
class Upload1ViewController: UIViewController ,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UITableViewDataSource, IndicatorInfoProvider
{

 
    var indexMedia : Int = 0
    @IBOutlet weak var viewNoDocs: UIView!
    var documents: DocumentObject?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "refresh-files_upload") { result in
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
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
            if  (MyVriables.currentMember?.gdpr?.files_upload)! == true {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
            }else
            {
                var gdprObkectas : GdprObject = GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false, parmter: "files_upload", image: "In order to use the files tools, please approve the files usage:")
                MyVriables.enableGdpr = gdprObkectas
                 self.performSegue(withIdentifier: "showEnableDocuments", sender: self)
            }

        }

        return cell
    }
    func removeFile(id: Int){
        ARSLineProgress.show()
        HTTP.POST(ApiRouts.Api+"/files/\(id)/group/\((MyVriables.currentGroup?.id)!)", parameters:[])
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
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let imageName = "temp.png"
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        print("IMAGEPATHOSH: " + imagePath)
        dismiss(animated: true, completion: nil)
        let imageData = UIImagePNGRepresentation(image)!
        print("AlamoUpload: START")
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        ARSLineProgress.show()
        var urlString: String = ApiRouts.Media + "/api/v2/upload/\((MyVriables.currentMember?.id!)!)?upload_type=group&group_id=\((MyVriables.currentGroup?.id)!)&file_type=\((self.documents?.required_documents[indexMedia].item)!)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file",fileName: "profile_image.jpg", mimeType: "image/jpg")
            
        },to:urlString)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    ARSLineProgress.hide()
                    self.getFilesUpload()
                }
                
                
            case .failure(let encodingError):
                print(encodingError)
                ARSLineProgress.hide()
                
            }
        }
        
    }
    func getFilesUpload() {
        
        //        ProviderInfo.model_id = (ProviderInfo.currentProviderId)!
        //        ProviderInfo.model_type = "activities"
        HTTP.GET(ApiRouts.Api+"/required_docs/members/\((MyVriables.currentMember?.id)!)/groups/\((MyVriables.currentGroup?.id)!)", parameters:[])
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
