//
//  GroupChatViewController.swift
//  Snapgroup
//
//  Created by hosen gaber on 7.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SocketIO
import SwiftHTTP
import SDWebImage
import ARSLineProgress
import Alamofire

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    var currentPage : Int = 1
    @IBOutlet weak var titleGroup: UILabel!
    @IBAction func sendMessage(_ sender: Any) {
        if (chatFeild?.text)! != ""
        {
            let message = (chatFeild?.text)!
        self.chatFeild?.text = ""
        print("message: \((chatFeild?.text)!)")
        if message != "" {
            let params = ["type":"text","message": message, "sender_id": (MyVriables.currentMember?.id!)!, "chat_type" : "group"
                , "group_id" : (MyVriables.currentGroup?.id!)! , "chat_id" : (MyVriables.currentGroup?.chat?.id)!
                ] as [String : Any]
            print("params: \(params)")
            
            HTTP.POST("\(ApiRouts.Api)/chats", parameters: params) { response in
                var newMessage :ChatListGroupItem = ChatListGroupItem()
                newMessage.message = message
                newMessage.type = "text"
                let today : String!
                today = getTodayString()
                newMessage.created_at = today
                newMessage.member_id = MyVriables.currentMember?.id!
                print(newMessage)
                DispatchQueue.main.async {
                    self.messages?.messages?.data!.append(newMessage)
                    self.chatTableView.reloadData()
                    self.scrollToLast()
                }
            }
        }
        }
    }
    @IBOutlet weak var chatFeild: UITextField!
    var chatMessages: [ChatListGroupItem]?
    var messages: ChatGroup?
    var chatsMessages: ChatGroup?
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    let imagePicker2 = UIImagePickerController()
    
    @IBOutlet weak var keyboardConstraitns: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var progressStar: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // like a comment but it isn't one
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
                view.addGestureRecognizer(tap)
        titleGroup.text = (MyVriables.currentGroup?
            .translations![0].title)!
        setSocket()
        imagePicker2.delegate = self
        chatFeild.autocorrectionType = .no
//        chatTableView.tableFooterView = UIView()
//        chatTableView.rowHeight = UITableViewAutomaticDimension
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        
        editView.layer.shadowOffset = CGSize.zero
        editView.layer.shadowRadius = 0.5
        editView.layer.shadowOffset = CGSize.zero
        editView.layer.shadowRadius = 1
        self.chatTableView.allowsMultipleSelection = true

        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowOffset = CGSize.zero
        headerView.layer.shadowRadius = 1
       
    }
    
    func setSocket(){
        
        print("----- ABED -----")
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        socket = manager.defaultSocket
        //"group-chat-"+groupId+":chat-message"
        socket!.on(clientEvent: .connect) {data, ack in
        self.socket!.emit("subscribe", "group-chat-\((MyVriables.currentGroup?.id)!)")
        }
        socket!.on("group-chat-\((MyVriables.currentGroup?.id)!):chat-message")
        { data, ack in
            print("onMessageRec: \(data[0])")
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["messageClass"] as? Dictionary<String, Any> {
                    var newMessage : ChatListGroupItem = ChatListGroupItem()
                    newMessage.created_at = messageClass["created_at"] as? String
                    newMessage.member_id = messageClass["member_id"] as? Int
                   
                    if let profile_image = data2["profile_image"] as? String {
                        newMessage.profile_image = profile_image
                    }
                    if  messageClass["image_path"] != nil {
                        newMessage.image_path = messageClass["image_path"] as? String
                    }
                    newMessage.message = messageClass["message"] as? String
                    newMessage.type = messageClass["type"] as? String
                    print(newMessage)
                    if (MyVriables.currentMember?.id)! != newMessage.member_id {
                       self.messages?.messages?.data!.append(newMessage)
                        self.chatTableView.reloadData()
                        self.scrollToLast()
                    }
                    else{
                        return
                    }

                    print(" good")
                    
                    
                    
                }
            }
            
        }
        
        
        socket!.onAny { (socEvent) in
            
            if let status =  socEvent.items as? [SocketIOStatus] {
                if let first = status.first {
                    switch first {
                    case .connected:
                        print("Socket: connected")
                        break
                        
                    case .disconnected:
                        print("Socket: disconnected")
                        break
                    case .notConnected:
                        print("Socket: notConnected")
                        break
                    case .connecting:
                        print("Socket: connecting")
                        break
                    default :
                        print("NOTHING")
                        break
                    }
                }
            }
        }
        
        self.socketManager = manager
        self.socket!.connect()
        
        
        
        
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        //    adjustingHeight(show: true, notification: notification)
        print("in keyboard show")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            keyboardConstraitns.constant = keyboardSize.height + 105
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.scrollToLast()
            }
        }

        
        // show keyboard hide
        
        
    }
    
    
    @IBAction func sendImage(_ sender: Any) {
        if  (MyVriables.currentMember?.gdpr?.files_upload)! == true {
            imagePicker2.allowsEditing = false
            imagePicker2.sourceType = .photoLibrary
            present(imagePicker2, animated: true, completion: nil)
        }else
        {
            var gdprObkectas : GdprObject = GdprObject(title: "Files upload and sharing", descrption: "Group leaders may request certain files and media to be uploaded for each group. These files will be available for the leader of the group you uploaded the files to. We will also save the uploaded files for you to use again. We may save these files for up to 3 months", isChecked: (MyVriables.currentMember?.gdpr?.files_upload) != nil ? (MyVriables.currentMember?.gdpr?.files_upload)! : false, parmter: "files_upload", image: "In order to use the files tools, please approve the files usage:")
            MyVriables.enableGdpr = gdprObkectas
            self.performSegue(withIdentifier: "showEnableDocuments", sender: self)
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
        var urlString: String = "\(ApiRouts.Media)/api/v2/upload_single_image/Member/\((MyVriables.currentMember?.id!)!)/media"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "single_image",fileName: "image.jpg", mimeType: "image/jpg")
          
            
        },to:urlString)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    ARSLineProgress.hide()
                    if let object = response.result.value as? Dictionary<String,AnyObject>{
                        if let imageobj = object["image"] as? Dictionary<String,Any>{
                            if let path = imageobj["path"] as? String{
                                print("DICTIONARY: LEVEL 2")
                                var oponent_id =  ChatUser.currentUser?.id!
                                var image_path = ApiRouts.Media + path
                                let params = ["type":"image","image_path": image_path  , "message": "", "sender_id": (MyVriables.currentMember?.id!)!, "chat_type" : "group", "group_id" : MyVriables.currentGroup?.id!, "chat_id" : MyVriables.currentGroup?.chat?.id!] as [String : Any]
                                print("params: \(params)")
                                HTTP.POST("\(ApiRouts.Api)/chats", parameters: params) { response in
                                    print("send chat: \(response.statusCode)" )
                                    var newMessage :ChatListGroupItem = ChatListGroupItem()
                                    newMessage.message = ""
                                    newMessage.type = "image"
                                    newMessage.image_path = image_path
                                    newMessage.member_id = MyVriables.currentMember?.id!
                                    print(newMessage)
                                    do{
                                        DispatchQueue.global().async(execute: {
                                            DispatchQueue.main.async {
                                                self.dismissKeyboard()
                                                self.messages?.messages?.data!.append(newMessage)
                                               // self.messages?.messages.append(newMessage)
                                                self.chatTableView.reloadData()
                                                self.scrollToLast()
                                            }
                                        })
                                        
                                    }catch {}
                                }
                            }
                            
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                ARSLineProgress.hide()
                
            }
        }
        
    }
    @objc   func keyboardWillHide(notification:NSNotification) {
        //   adjustingHeight(show: false, notification: notification)
        print("in keyboard hide")
        
       if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            keyboardConstraitns.constant = 70
        }

    }
   
    override func viewWillAppear(_ animated: Bool) {
         getGroupHistory(isFirstTimee: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.currentPage = 1
        socket?.disconnect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messages?.messages?.data!.count) != nil {
        print("Array count is \((self.messages?.messages?.data!.count)!)")
            
            return (self.messages?.messages?.data!.count)!
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "partnerTextCell", for: indexPath) as! PartnerTextCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "meTextCell", for: indexPath) as! MeTextCell
        let imageMeCell = tableView.dequeueReusableCell(withIdentifier: "imageMeCell", for: indexPath) as! ImageMeCell
          let imagePartnerCell = tableView.dequeueReusableCell(withIdentifier: "imagePartnerCell", for: indexPath) as! ImagePartnerCell
           let filePartnerCell = tableView.dequeueReusableCell(withIdentifier: "partnerFileCell", for: indexPath) as! PartnerFileCell
          let fileMeCell = tableView.dequeueReusableCell(withIdentifier: "meFileCell", for: indexPath) as! MeFileCell
        if (self.messages?.messages?.data![indexPath.row].created_at) != nil {
            let createdAt : String =  (((self.messages?.messages?.data![indexPath.row].created_at))!.components(separatedBy: " ")[1])
            cell.time.text = gmtToLocal(date: createdAt)
            cell2.time.text = gmtToLocal(date: createdAt)
            imageMeCell.time.text = gmtToLocal(date: createdAt)
            imagePartnerCell.time.text = gmtToLocal(date: createdAt)
            
        }else
        {
            cell.time.text = ""
            cell2.time.text = ""
            imageMeCell.time.text = ""
            imagePartnerCell.time.text = ""
            
        }
        imageMeCell.imageViewClick.addTapGestureRecognizer {
            if (self.messages?.messages?.data![indexPath.row].type)! == "image"
                    {
                        MyVriables.imageUrl = (self.messages?.messages?.data![indexPath.row].image_path)!
                        self.performSegue(withIdentifier: "showImageSegue", sender: self)
            }
        }
        imagePartnerCell.imageViewClick.addTapGestureRecognizer {
            if (self.messages?.messages?.data![indexPath.row].type)! == "image"
            {
                MyVriables.imageUrl = (self.messages?.messages?.data![indexPath.row].image_path)!
                self.performSegue(withIdentifier: "showImageSegue", sender: self)
            }
        }
        if self.messages?.messages?.data![indexPath.row].member_id! == MyVriables.currentMember?.id!
        {
            if (self.messages?.messages?.data![indexPath.row].type)! == "text"
            {
                if self.messages?.messages?.data![indexPath.row].message != nil {
                    cell2.textLbl.text = (self.messages?.messages?.data![indexPath.row].message!)!
                }
                return cell2
            }
            else
            {
                if (self.messages?.messages?.data![indexPath.row].type)! == "image"
                {
                    if (self.messages?.messages?.data![indexPath.row].image_path) != nil
                    {
                        var urlString = ""
                        
                        if (self.messages?.messages?.data![indexPath.row].image_path)!.contains("http")
                        
                        {
                            urlString = (self.messages?.messages?.data![indexPath.row].image_path)!
                        }
                        else
                        {
                            urlString = try ApiRouts.Media + (self.messages?.messages?.data![indexPath.row].image_path)!
                        }
                       print("Url string is \(urlString)")
                        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                        var url = URL(string: urlString)
                        if url != nil {
                            imageMeCell.meImage?.af_setImage(withURL: url!)
                        }
                    }
                    return imageMeCell
                }
                else
                {
                    return fileMeCell
                }
            }
            
            
        }
        else {
            
            do{
                if self.messages?.messages?.data![indexPath.row].profile_image != nil{
                    if "snapgroup" == (self.messages?.messages?.data![indexPath.row].profile_image)!
                    {
                        cell.partnerProfile.image = UIImage(named: "new logo")
                        imagePartnerCell.partnerImageProfile.image = UIImage(named: "new logo")
                        
                    }
                    else
                    {
                    let urlString = try ApiRouts.Media + (self.messages?.messages?.data![indexPath.row].profile_image)!
                    let url = URL(string: urlString)
                    cell.partnerProfile.sd_setImage(with: url!, completed: nil)
                    imagePartnerCell.partnerImageProfile.sd_setImage(with: url!, completed: nil)
                    }
                    cell.partnerProfile.layer.cornerRadius =  cell.partnerProfile.frame.size.width / 2;
                     cell.partnerProfile.clipsToBounds = true;
                    cell.partnerProfile.layer.borderWidth = 1.0
                     cell.partnerProfile.layer.borderColor = UIColor.gray.cgColor
                    
                    imagePartnerCell.partnerImage.layer.cornerRadius = imagePartnerCell.partnerImage.frame.size.width / 2;
                    imagePartnerCell.partnerImage.clipsToBounds = true;
                    imagePartnerCell.partnerImage.layer.borderWidth = 1.0
                    imagePartnerCell.partnerImage.layer.borderColor = UIColor.gray.cgColor
                }
                else
                {
                    cell.partnerProfile.image = UIImage(named: "default user")
                    imagePartnerCell.partnerImageProfile.image = UIImage(named: "default user")
                }
            }catch let error {
               
            }
            if self.messages?.messages?.data![indexPath.row].type! == "text"
            {
                
                if self.messages?.messages?.data![indexPath.row].sender_name != nil {
                    cell.partnerName.text = (self.messages?.messages?.data![indexPath.row].sender_name!)!
                }
                if (self.messages?.messages?.data![indexPath.row].message) != nil {

                    //print(" MESSAGE IS : \((self.messages?.messages?[indexPath.row].message!)!)")
                    cell.textLbl.text = "\((self.messages?.messages?.data![indexPath.row].message!)!)"
                   
                }
                 return cell
            }
            else
            {
                if self.messages?.messages?.data![indexPath.row].sender_name != nil {
                    imagePartnerCell.partnerName.text = (self.messages?.messages?.data![indexPath.row].sender_name!)!
                }
                if (self.messages?.messages?.data![indexPath.row].type)! == "image"
                {
                    if (self.messages?.messages?.data![indexPath.row].image_path)! != nil
                    {
                        var urlString: String
                        print("THIS IS   "+"\((self.messages?.messages?.data![indexPath.row].image_path)!)")
                        if (self.messages?.messages?.data![indexPath.row].image_path)!.range(of: "http") != nil{
                            urlString = (self.messages?.messages?.data![indexPath.row].image_path)!
                        }
                        else {
                            urlString = try ApiRouts.Media + (self.messages?.messages?.data![indexPath.row].image_path)! }
                       urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                        let url = URL(string: urlString)
                        if url != nil{
                            imagePartnerCell.partnerImage.sd_setImage(with: url!, completed: nil)}
                    }
                   
                    return imagePartnerCell
                    //imageMeCell.meImage.image = UIImage
                }
                else
                {
                    return filePartnerCell
                }
                
            }
            
           
        }
     
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Type is \((self.messages?.messages![indexPath.row].type)!)")
//        if (self.messages?.messages![indexPath.row].type)! == "image"
//        {
//            MyVriables.imageUrl = (self.messages?.messages![indexPath.row].image_path)!
//            performSegue(withIdentifier: "showImageSegue", sender: self)
//        }
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected selected ")
    }
    func getGroupHistory(isFirstTimee: Bool){
        print("Group chat " + ApiRouts.Api+"/chats/messages?chat_id=\((MyVriables.currentGroup?.chat?.id!)!)&page=\(self.currentPage)")
        HTTP.GET(ApiRouts.Api+"/chats/messages?chat_id=\((MyVriables.currentGroup?.chat?.id!)!)&page=\(self.currentPage)", parameters: ["hello": "world", "param2": "value2"])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            //print("responseeee "+response.description)
            do{
          let chatMesagesHelper  = try JSONDecoder().decode(ChatGroup.self, from: response.data)
            //print("responseeeeaasd \(self.messages!)")
                DispatchQueue.main.sync {
                    
                    print("Total is \((chatMesagesHelper.messages?.total)!)")
                    if (chatMesagesHelper.messages?.total)! == 0
                    {
   
                        self.messages = chatMesagesHelper

                        print("Total is true")
                         self.messages?.messages?.data! = []
                        var groupItem :ChatListGroupItem = ChatListGroupItem()
                        groupItem.sender_name = "Snapgroup"
                        groupItem.member_id = 0
                        groupItem.type = "text"
                        groupItem.profile_image = "snapgroup"
                        groupItem.message = "Welcome to the group chat.Here you can share text messages and images with the rest of the group members."
                        self.messages?.messages?.data!.insert(groupItem, at: 0)
                       // self.messages?.messages?.data?.append(groupItem)
                        
                        
                        print("Group chat count now is \(self.messages?.messages?.data?.count)")
                        self.chatTableView.reloadData()
                        self.progressStar.isHidden = true
                        
                    }
                    else
                    {

                        var current_Page1 : Int = (chatMesagesHelper.messages?.current_page)!
                        var last_Page1 : Int = (chatMesagesHelper.messages?.last_page)!
                        print("Current page is \(current_Page1) and last page is \(last_Page1)")
                        if current_Page1 > last_Page1
                        {
                            self.isHasMore = false
                            self.progressStar.isHidden = true
                        }
                        self.currentPage = (chatMesagesHelper.messages?.current_page!)! + 1
                        if isFirstTimee{
                            self.messages = chatMesagesHelper
                            self.messages?.messages?.data!.reverse()
                            self.chatTableView.reloadData()
                            self.scrollToLast()
                        }else
                        {
                            var appenArray = (chatMesagesHelper.messages?.data!)!
                            appenArray.reverse()
                        self.messages?.messages?.data!.insert(contentsOf: appenArray, at: 0)
                            var initialOffset = self.chatTableView.contentOffset.y
                            self.chatTableView.reloadData()
                            var indexScrollTo = ((appenArray).count) + 1
                            print("Scroll to \(appenArray.count)")
                            self.chatTableView.scrollToRow(at: IndexPath(row: (appenArray.count), section: 0), at: .top, animated: false)
                            self.chatTableView.contentOffset.y += initialOffset
                        }
                        if (self.messages?.messages?.data!.count)! > 0 {
                            self.topVisibleIndexPath = self.chatTableView.indexPathsForVisibleRows![0]
                        }
                        self.isLoading = false
                        self.progressStar.isHidden = true
                        
                        
                    }
                    
                    
                }
            }
            catch {
                
            }
    
            
        }
        
        
    }
    var topVisibleIndexPath:IndexPath? = nil
    var isLoading: Bool = false
    var isFirstTime: Bool = true
    var scrollPostion: CGFloat?
    var isHasMore: Bool = true
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("Display is ime here and top is \(self.chatTableView.indexPathsForVisibleRows![0].row)")
//         print("Display is  top is \(topVisibleIndexPath?.row)")
        if isFirstTime {
            return
        }
        
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
        }else {
            if (self.messages?.messages?.data!.count)! > 0 {
                topVisibleIndexPath = self.chatTableView.indexPathsForVisibleRows![0]
            }
        }
        print("STATEMNT IS topVisibleIndexPath?.row == 0 = \(topVisibleIndexPath?.row == 0)")
        scrollPostion = chatTableView.contentOffset.y
        if topVisibleIndexPath?.row == 0 && isHasMore {
            print("HOSEN - in first if")
            if !isLoading {
                print("TESTTEST- load more data .. ")
                isLoading = true
                print("TESTTEST- load more data .. ")
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                    // HERE LOAD NEW MESSAGES ...
                    var savedIndex = tableView.indexPathsForVisibleRows?.first
                    let indexPathOfFirstRow = NSIndexPath(row: 0, section: 0)
                    self.progressStar.isHidden = false
                    self.getGroupHistory(isFirstTimee: false)
                    
                    
                    if (self.messages?.messages?.data!.count)! > 0 {
                        //                    let indexPath = IndexPath(row: (self.chatTableView.indexPathsForVisibleRows![0].row)+2 , section: 0)
                        //                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    
                    
                    // FINISH LOAD NEW ITMES
                    
                    
                }
            }
        }
        else
        {
            self.progressStar.isHidden = true
        }
    }
  
    func scrollToLast(){
    
        if (self.messages?.messages?.data) != nil {
        if (self.messages?.messages?.data?.count)! > 0 {
            let indexPath = IndexPath(row: (self.messages?.messages?.data?.count)! - 1 , section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        }
        self.isFirstTime = false
        
    }

}
