//
//  MenuViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/26/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftEventBus

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    // HI 11122
    
    
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
class MenuViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var arrivalImage: UIImageView!
    @IBOutlet weak var groupNameLbl: UILabel!
    var singleGroup: TourGroup?
    var countdownTimer: Timer!
    var totalTime = 60
    let date = Date()
    let formatter = DateFormatter()
    @IBOutlet weak var arrivalConfirmationView: UIControl!
    @IBOutlet weak var groupHomeView: UIView!
    @IBOutlet weak var rolesView: UIControl!
    @IBOutlet weak var roomlistView: UIControl!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var recuringView: UIView!
    @IBOutlet weak var mapsView: UIControl!
    @IBOutlet weak var leaderView: UIControl!
    @IBOutlet weak var paymentsView: UIControl!
    @IBOutlet weak var membersView: UIControl!
    @IBOutlet weak var docsView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var itineraryView: UIView!
    @IBOutlet weak var checkListView: UIControl!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    @IBOutlet weak var secLbl: UILabel!
    @IBOutlet weak var groupChatView: UIControl!
    
    @IBOutlet weak var backToDeatils: UIStackView!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var backView: UIView!
    var timer1 = Timer()
    var arrives: ArriveChecked?
    var secondsLeft: Int?
   
    override func viewWillAppear(_ animated: Bool) {
        if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
            recuringView.isHidden = false
            timeView.isHidden = true
        }else{
            recuringView.isHidden = true
            timeView.isHidden = false
        }
        self.singleGroup  = MyVriables.currentGroup!
        if MyVriables.currentGroup?.registration_end_date != nil {
           calculateRegisterDate( date : (MyVriables.currentGroup?.registration_end_date!)!)
        }
        print("view xcontroler \(MyVriables.shouldRefreshBusStation)")
        if MyVriables.shouldRefreshBusStation{
            
            if (self.singleGroup?.group_tools?.arrival_confirmation!)! == true
            {      if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                getArriveChecked()
                MyVriables.shouldRefreshBusStation = false
                }
            }
        }
    }
    fileprivate func bookNowFunc() {
        if MyVriables.currentGroup?.role != nil &&  (MyVriables.currentGroup?.role)! != "observer"
        {
            MyVriables.isBookClick = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
            self.navigationController?.pushViewController(vc,animated: true)
            
        }else{
            MyVriables.isBookClick = true
            self.tabBarController?.selectedIndex = 1
        }
    }
    @IBAction func bookNoewClick(_ sender: Any) {
        setCheckTrue(type: "book_now", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    @IBAction func avilbleDateClick(_ sender: Any) {
        setCheckTrue(type: "available_dates", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer1.invalidate()
        // self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer1.invalidate()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("hioooosh")
        self.setAlphaView()
    }
    func viewsClick() {
        membersView.addTapGestureRecognizer {
            
            if (self.singleGroup?.group_tools?.members!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    self.performSegue(withIdentifier: "showMembers", sender: self)
                }
            }
            
        }
        backView.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 0
            
        }
        groupHomeView.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 0
            
        }
        paymentsView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.payments!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    setCheckTrue(type: "booking", groupID: (MyVriables.currentGroup?.id)!)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            }
            
        }
        rolesView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "rolesSegue", sender: self)
            
        }
        mapsView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.map!)! == true
            {
                self.performSegue(withIdentifier: "showMainMap", sender: self)
                //showMainMap
                //self.performSegue(withIdentifier: "showTest", sender: self)
            }
            
        }
        servicesView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.services!)! == true
            {
                self.performSegue(withIdentifier: "showNewServices", sender: self)
            }
            
        }
        itineraryView.addTapGestureRecognizer {
            
            if (self.singleGroup?.group_tools?.itinerary!)! == true
            {
                self.performSegue(withIdentifier: "showPlanSegue", sender: self)
            }
        }
        docsView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.documents!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    self.performSegue(withIdentifier: "showDocsSegue", sender: self)
                }
                
            }
            
            
        }
        groupChatView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.chat!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    self.performSegue(withIdentifier: "showChatGroup", sender: self)
                }
                
            }
            
            
        }
        checkListView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.checklist!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    self.performSegue(withIdentifier: "showCheckList", sender: self)
                }
            }
            
            
        }
        leaderView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.group_leader!)! == true
            {
                self.performSegue(withIdentifier: "showLeaderSegue", sender: self)
            }
        }
        arrivalConfirmationView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.arrival_confirmation!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    self.performSegue(withIdentifier: "showArrivalConfirmation", sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentLbl.text = "Booking"
              print("view xcontroler 231 \(MyVriables.shouldRefreshBusStation)")
        self.singleGroup  = MyVriables.currentGroup!
        if singleGroup?.translations?.count == 0 {
            self.groupNameLbl.text = singleGroup?.title
        }
        else {
            self.groupNameLbl.text = singleGroup?.translations?[0].title

        }
        
        
        if (self.singleGroup?.group_tools?.arrival_confirmation!)! == true
        {
            getArriveChecked()
        }
        setAlphaView()
        print("group tools \((self.singleGroup?.group_tools?.chat!)!)")
        self.groupNameLbl.numberOfLines = 0
        self.groupNameLbl.lineBreakMode = .byWordWrapping
        viewsClick()
        
        startTimer()
        // Do any additional setup after loading the view.
    }
    
    @objc func runScheduledTask(_ runningTimer: Timer) {
        var hour: Int
        var minute: Int
        var second: Int
        var  day: Int

        self.secondsLeft = self.secondsLeft! - 1
        
        if secondsLeft! == 0  || secondsLeft! < 0{
            timer1.invalidate()
            
        }
        else {
           
            hour = secondsLeft! / 3600
            minute = (secondsLeft! % 3600) / 60
            second = (secondsLeft! % 3600) % 60
            day = ( secondsLeft! / 3600) / 24
            if(day > 0){
                hour = (secondsLeft! / 3600) % (day * 24)
            }
            daysLbl.text = String(format: "%02d", day)
            minLbl.text = String(format: "%02d", minute)
            secLbl.text = String(format: "%02d", second)
            hoursLbl.text = String(format: "%02d", hour)
        }
        
    }
    func calculateRegisterDate(date: String)
    {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("DDDAAATTEEE: "+formatter.string(from: currentDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatter.date(from: date)!
        print("REG END DATE: "+dateFormatter.string(from: date2))
        let days = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day!
        let hours = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour!
        let mintus = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).minute!
        let seconds = Calendar.current.dateComponents([.day,.second,.hour,.minute,.month], from: currentDate, to: date2).second!
        let minToSecs = mintus * 60
        let hourstoSecs = hours * 60 * 60
        let daysToSecs = days * 24 * 60 * 60
        let allSec = minToSecs + hourstoSecs + daysToSecs + seconds
     
        print("days: \(days) , hours: \(hours)")
        if days < 0 || hours < 0 {
            print("Closed")
        }
        else{
            daysLbl.text = String(format: "%02d", days)
            minLbl.text = String(format: "%02d", mintus)
            secLbl.text = String(format: "%02d", seconds)
            hoursLbl.text = String(format: "%02d", hours)
            self.secondsLeft = allSec
            
            self.timer1  = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.runScheduledTask), userInfo: nil, repeats: true)
            print("\(days) d' \(hours) h'  and \(mintus) mintus and \(seconds) sec to join")
        }
        
        //   print(date)
    }
    func setAlphaView()
    {
        if (self.singleGroup?.role) == nil
        {
             self.membersView.alpha = 0.3
            self.paymentsView.alpha = 0.3
            self.checkListView.alpha = 0.3
             self.roomlistView.alpha = 0.3
             self.docsView.alpha = 0.3
            self.arrivalConfirmationView.alpha = 0.3
            self.groupChatView.alpha = 0.3
        }
        else
        {
             if (self.singleGroup?.role)! == "observer"
             {
                 self.membersView.alpha = 0.3
                self.paymentsView.alpha = 0.3
                self.checkListView.alpha = 0.3
                self.roomlistView.alpha = 0.3
                self.docsView.alpha = 0.3
                self.arrivalConfirmationView.alpha = 0.3
                  self.groupChatView.alpha = 0.3
            }
            else
             {
                 self.membersView.alpha = 1
                self.paymentsView.alpha = 1
                self.checkListView.alpha = 1
               // self.roomlistView.alpha = 1
                self.docsView.alpha = 1
                self.arrivalConfirmationView.alpha = 1
                self.groupChatView.alpha = 1
            }
        }
        if (self.singleGroup?.group_tools?.chat!)! == false
        {
            self.groupChatView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.members!)! == false
        {
            self.membersView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.payments!)! == false
        {
              self.paymentsView.alpha = 0.3
            self.paymentsView.backgroundColor = UIColor.clear
        }else{
          
            if (MyVriables.currentGroup?.role) != nil && ((MyVriables.currentGroup?.role)! != "member" || (MyVriables.currentGroup?.role)! != "group_leader")
            {
                self.paymentsView.alpha = 1
                paymentsView.layer.cornerRadius = 10
                // border
                paymentsView.layer.borderWidth = 0.5
                paymentsView.layer.borderColor = Colors.PrimaryColor.cgColor
                
                // shadow
                paymentsView.layer.shadowColor = UIColor.black.cgColor
                paymentsView.layer.shadowOffset = CGSize(width: 1, height: 1)
                paymentsView.layer.shadowOpacity = 0.7
                paymentsView.layer.shadowRadius = 2.0
                
            }else{
                self.paymentsView.alpha = 0.3
                self.paymentsView.backgroundColor = UIColor.clear

            }
           
        }
        if (self.singleGroup?.group_tools?.rooming_list!)! == false
        {
            self.roomlistView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.group_leader!)! == false
        {
            self.leaderView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.itinerary!)! == false
        {
            self.itineraryView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.map!)! == false
        {
            self.mapsView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.documents!)! == false
        {
            self.docsView.alpha = 0.3
        }
      //   self.docsView.alpha = 0.3
        if (self.singleGroup?.group_tools?.checklist!)! == false
        {
            self.checkListView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.services!)! == false
        {
            self.servicesView.alpha = 0.3
        }
        
        if (self.singleGroup?.group_tools?.arrival_confirmation!)! == false
        {
            self.arrivalConfirmationView.alpha = 0.3
        }
        
        
    }
    @IBOutlet weak var paymentLbl: UILabel!
    func uploadImageToServer(){
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        
//        let fileUrl = URL(fileURLWithPath: "/Users/snapmac/Downloads/leader.png")
//        HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: fileUrl)]) { response in
//
//            print(response.description)
//            //do things...
//        }
    }
    func getArriveChecked(){
        //print("from menu   "+ApiRouts.Web+"/api/members/\((MyVriables.currentMember?.id!)!)/groups/\((MyVriables.currentGroup?.id!)!)/stations")
       
        if MyVriables.currentMember == nil
        {
            
        }
        else
        {
        HTTP.GET(ApiRouts.Api+"/members/\((MyVriables.currentMember?.id!)!)/groups/\((MyVriables.currentGroup?.id!)!)/stations", parameters: [])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do
            {
                self.arrives  = try JSONDecoder().decode(ArriveChecked.self, from: response.data)
                DispatchQueue.main.sync {
                 if self.arrives?.going == true
                 {
                    self.arrivalImage.image = UIImage(named: "checkedArrive")
                }
                else
                 {
                    self.arrivalImage.image = UIImage(named: "arrivle_confirmation")
                }
                    
                }
            }
            catch {
                
            }
            
            print(response.description)
            
        }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //var image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        var urlosh: URL = (info[UIImagePickerControllerReferenceURL] as! URL)
        let imageName = urlosh.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as! String
        let localPath = documentDirectory.appending(imageName)
        
        let fileUrl = URL(fileURLWithPath: localPath)

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = UIImagePNGRepresentation(image)
            do{
                try  data?.write(to: fileUrl, options: .atomic)
                print("success to data")
                
            }catch {
                print("error")
            }
            
            let imageData = NSData(contentsOfFile: localPath)!
            let photoURL = URL(fileURLWithPath: localPath)
            
            let imageWithData = UIImage(data: imageData as Data)!
            // self.uploadImage(image: image)
            print(photoURL)
            print("before post ")
//            HTTP.POST("https://api.snapgroup.co.il/api/upload_single_image/Member/74/profile", parameters: ["single_image": Upload(fileUrl: photoURL)]) { response in
//                print("during post ")
//
//                if let err = response.error {
//                    print("error: \(err.localizedDescription)")
//                    return //also notify app of failure as needed
//                }
//                print(response)
//                //do things...
//
//
//        }
    
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func onBackPressed(_ sender: Any) {
      self.tabBarController?.selectedIndex =  0   }
    
    @objc func membersClick(){
        print("tapped")
        
    }
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        counterLbl.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
//    @IBAction func goToMembers(_ sender: Any) {
//        print("pressed")
//        performSegue(withIdentifier: "showMembers", sender: self)
//
//    }
 
    
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func uploadImage(image: UIImage)
    {
        let imageData = UIImageJPEGRepresentation(image, 1)

        if imageData == nil { return }
        print(imageData)
    }
    
    
    

}
