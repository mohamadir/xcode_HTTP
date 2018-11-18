//
//  DetailsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 2/25/18.
//  Copyright © 2018 snapmac. All rights reserved.
//
import UIKit
import Auk
import ImageSlideshow
import SwiftHTTP
import SwiftEventBus
import Scrollable
import ARSLineProgress
import BmoViewPager
import GoogleMaps
import GooglePlaces
import TTGSnackbar


extension String {
    var utfData: Data? {
        return self.data(using: .utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        guard let data = self.utfData else {
            return nil
        }
        do {
            
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
class DetailsViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource,GMSMapViewDelegate
, CLLocationManagerDelegate {

    var locationManager =  CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var currnetIndex: Int = 0
    var countdownTimer: Timer!
    var totalTime = 60
    @IBOutlet weak var companyPage: UILabel!
    @IBOutlet weak var companyDiscrption: UILabel!
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var companLbl: UILabel!
    @IBOutlet weak var companyView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bookNowView: UIView!
    @IBOutlet var groupLeaderView: UIView!
    @IBOutlet weak var tagLineConstrate: NSLayoutConstraint!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var tagLineView: UIView!
    var images2: [InputSource] = []
    @IBOutlet var joinView: UIView!
    @IBOutlet var leftToJoinLbl: UILabel!
    @IBOutlet weak var tagLineLbl: UILabel!
    @IBOutlet weak var priceWithSale: UIView!
    
    let cvv: ViewController  = ViewController()
     var groupImages: [GroupImage] = []
    @IBOutlet var scrollView: UIScrollView!
    var singleGroup: TourGroup?
    
    var counterLbl : UILabel = UILabel()
    // time for regstrtion
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    @IBOutlet weak var secLbl: UILabel!
    var timer1 = Timer()
    var secondsLeft: Int?
    
    // recuuring group
    @IBOutlet weak var reccuring_group: UIView!
    @IBOutlet weak var frequency: UILabel!
    @IBOutlet weak var timeRecurrnig: UILabel!
    /// intenery
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var shoeMoreDayDescrption: UILabel!
    @IBOutlet weak var viewpagerHigh: NSLayoutConstraint!
    @IBOutlet weak var pickerInterry: UIPickerView!
    @IBOutlet weak var dayDescrption: UILabel!
    @IBOutlet weak var titleGroup: UILabel!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var interryImageView: UIImageView!
    @IBOutlet weak var dateGroup: UILabel!
    var planDays: [Day] = []
    var pickerData: [String] = ["1","2","3"]
    @IBOutlet weak var overView: UIView!
    
    @IBOutlet weak var mapOver: UIView!
    // services views
    public var currentDay: Day?
    @IBOutlet weak var hotelsView: UIView!
    @IBOutlet weak var activitiesView: UIView!
    @IBOutlet weak var restaurantView: UIView!
    @IBOutlet weak var transportsView: UIView!
    @IBOutlet weak var tourGuideView: UIView!
    @IBOutlet weak var placesViews: UIView!
    
    // services labels views
    @IBOutlet weak var hotelsLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var activitiesLbl: UILabel!
    @IBOutlet weak var placesLbl: UILabel!
    @IBOutlet weak var transportsLbl: UILabel!
    @IBOutlet weak var toursLbl: UILabel!
    
    
    
    /// group apps views
    @IBOutlet weak var arrivalConfirmationView: UIControl!
    @IBOutlet weak var rolesView: UIControl!
    @IBOutlet weak var mapsView: UIControl!
    @IBOutlet weak var paymentsView: UIControl!
    @IBOutlet weak var membersView: UIControl!
    @IBOutlet weak var docsView: UIView!
    @IBOutlet weak var checkListView: UIControl!
    @IBOutlet weak var groupChatView: UIControl!
    
    @IBOutlet weak var termsView: UIView!
    ////////////
    @IBOutlet var groupAppView: UIView!
    @IBOutlet var slideShow: ImageSlideshow!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var showMoreButton: UIButton!
    var isCollapsed: Bool = false
    
    @IBOutlet weak var arrivalConfirmView: UIView!
    @IBOutlet weak var viewGetY: UIView!
    @IBOutlet weak var filterTwo: UIView!
    @IBOutlet weak var filterThree: UIView!
    @IBOutlet weak var filterOne: UIView!
    @IBOutlet weak var pricesView: UIView!
    @IBOutlet var member_status_view: UIView!
    @IBOutlet var member_status_lbl: UILabel!
    @IBOutlet weak var footerImage: UIImageView!
    @IBOutlet var member_Status_Im: UIImageView!
    @IBOutlet var groupLeaderImageView: UIImageView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var stackGroupLeader: UIStackView!
    @IBOutlet weak var gradinet: UIView!
    @IBOutlet var companyLbl: UILabel!
    @IBOutlet var groupLeaderNameLbl: UILabel!
    @IBOutlet var tripDurationLbl: UILabel!
    @IBOutlet weak var googleMaps: GMSMapView!
    public var hightScroll:Float = 0
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var roleTxt: UILabel!
    var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var groupTitleLb: UILabel!
    
    @IBAction func confirmArriveClick(_ sender: Any) {
         if MyVriables.currentGroup?.role != nil &&  (MyVriables.currentGroup?.role)! != "observer"
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ArrivleConfirmationViewController") as! ArrivleConfirmationViewController
            self.navigationController?.pushViewController(vc,animated: true)
            
         }else {
            let snackbar = TTGSnackbar(message: "You must be join to the group to confirm arrival", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
            
        }
        
    }
    fileprivate func getGroupImages() -> HTTP? {
        return HTTP.GET("\(ApiRouts.Api)/groups/\((MyVriables.currentGroup?.id)!)/images", parameters: []) { response in
            if response.error != nil {
                print("error \(response.error?.localizedDescription)")
                return
            }
            do {
                let images = try JSONDecoder().decode([GroupImage].self, from: response.data)
                print ("successed")
                DispatchQueue.main.sync {
                    self.groupImages = images
                    if self.groupImages.count == 0 {
                        self.slideShow.setImageInputs([
                            ImageSource(image: UIImage(named: "Group Placeholder")!)])
                    }else {
                        
                        var image_path: String = ""
                        for image in self.groupImages {
                            if image.path !=  nil {
                                
                                image_path = "\(ApiRouts.Media)\(image.path!)"
                                image_path = image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                                print("Image payjso \(image_path)")
                                if AlamofireSource(urlString: image_path) != nil  {
                                    self.images2.append(AlamofireSource(urlString: image_path)!)
                                }
                            }
                        }
                        self.slideShow.contentScaleMode = .scaleAspectFill
                        self.slideShow.contentMode = .scaleAspectFill
                        self.slideShow.setImageInputs(self.images2)
                    }
                }
            }
            catch{
                
            }
            //do things...
        }
    }
    @IBAction func moreInfoClick(_ sender: Any) {
        //intrsted
        self.tabBarController?.selectedIndex = 2
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
    
    @IBAction func bookNowClick(_ sender: Any) {
         setCheckTrue(type: "book_now", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    @IBOutlet weak var roleSection: UIView!
    @IBAction func availbleDateClick(_ sender: Any) {
        setCheckTrue(type: "available_dates", groupID: (MyVriables.currentGroup?.id)!)
        bookNowFunc()
    }
    func countLabelLines(label: UILabel) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        print("Label us \(label.text)")
        let myText = label.text! as String
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: label.font], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    var rotationAngle: CGFloat!
    @IBOutlet weak var showMoreTerms: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        shoeMoreDayDescrption.addTapGestureRecognizer(action: {
            if self.shoeMoreDayDescrption.text == "Show More"
            {
                self.dayDescrption.numberOfLines = 0
                self.dayDescrption.sizeToFit()
                self.shoeMoreDayDescrption.text = "Show Less"
            }else {
                self.dayDescrption.numberOfLines = 3
                self.dayDescrption.sizeToFit()
                self.shoeMoreDayDescrption.text = "Show More"
            }
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        })
        
        googleMaps.accessibilityLanguage = "en"
        viewsClicked(indexpathDay: 0)
        groupAppView.addTapGestureRecognizer {
            self.tabBarController?.selectedIndex = 1
        }
        mapOver.addTapGestureRecognizer {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainMapViewController") as! MainMapViewController
            self.navigationController?.pushViewController(vc,animated: true)
            
        }
        
        //roleTxt
        if MyVriables.currentGroup?.group_conditions != nil {
            termsView.layer.cornerRadius = 5
            // border
            
            termsView.layer.borderWidth = 0.5
            termsView.layer.borderColor = Colors.PrimaryColor.cgColor
            
            // shadow
            termsView.layer.shadowColor = UIColor.black.cgColor
            termsView.layer.shadowOffset = CGSize(width: 1, height: 1)
            termsView.layer.shadowOpacity = 0.2
            termsView.layer.shadowRadius = 2.0
            termsView.backgroundColor = Colors.paymentsBacground
            roleTxt.setHtmlText((MyVriables.currentGroup?.group_conditions!)!)
            if roleTxt.calculateMaxLines() > 10 {
                showMoreTerms.isHidden = false
            }else {
                showMoreTerms.isHidden = true
            }
        }else {
            
            roleSection.isHidden = true
        }
        showMoreTerms.addTapGestureRecognizer {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RolesViewController") as! RolesViewController
            self.navigationController?.pushViewController(vc,animated: true)
        }
        companyView.addTapGestureRecognizer {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CompanyViewController") as! CompanyViewController
        self.navigationController?.pushViewController(vc,animated: true)
            //CompanyViewController
        }
        
        interryImageView.layer.cornerRadius = 5
        overView.layer.cornerRadius = 5
        // border
        
        overView.layer.borderWidth = 0.5
        overView.layer.borderColor = Colors.PrimaryColor.cgColor

        // shadow
        overView.layer.shadowColor = UIColor.black.cgColor
        overView.layer.shadowOffset = CGSize(width: 1, height: 1)
        overView.layer.shadowOpacity = 0.2
        overView.layer.shadowRadius = 2.0
        overView.backgroundColor = Colors.paymentsBacground
//        bmoPageViewer.delegate = self
//        bmoPageViewer.dataSource = self
        getDays()
        joinView.layer.borderColor = Colors.PrimaryColor.cgColor
        joinView.layer.borderWidth = 1
        ARSLineProgress.hide()
        rotationAngle = -1 * (90 * (.pi/180))
        pickerInterry.transform = CGAffineTransform(rotationAngle: rotationAngle )
        pickerInterry.frame = CGRect(x: -100, y: overView.frame.origin.y - 80, width: UIScreen.main.bounds.width + 200, height: 60)
        pickerInterry.delegate = self
        pickerInterry.dataSource = self
        descriptionLbl.text = (MyVriables.currentGroup?.translations?[0].description)!
        print("Lavel is \(descriptionLbl.text)")
        if descriptionLbl.calculateMaxLines() > 3 {
            showMoreButton.isHidden = false
        }
        else{
            showMoreButton.isHidden = true
        }
        print("descrption lines is \(descriptionLbl.calculateMaxLines())")

        //showMoreButton
        //member
        if MyVriables.currentGroup!.special_price_tagline != nil {
            self.tagLineView.isHidden = false
            self.tagLineLbl.text = "\((MyVriables.currentGroup!.special_price_tagline)!)"
           // self.tagLineConstrate.constant = 90
            
        }else
        {
            //self.tagLineConstrate.constant = 60
             self.tagLineView.isHidden = true
        }
        
        //member
        if MyVriables.currentGroup!.price != nil {
            pricesView.isHidden = false
            self.price.text = "£\((MyVriables.currentGroup!.price)!)"
        }else
        {
            pricesView.isHidden = true
            self.price.text = ""
        }
        if MyVriables.currentGroup!.special_price != nil {
            
            if MyVriables.currentGroup!.price != nil {
                pricesView.isHidden = true
                priceWithSale.isHidden = false
                oldPrice.text = "£\((MyVriables.currentGroup!.price)!)"
                newPrice.text = "£\((MyVriables.currentGroup!.special_price)!)"
            }else {
                priceWithSale.isHidden = true
                pricesView.isHidden = false
            self.price.text = "£\((MyVriables.currentGroup!.special_price)!)"
         
            
            }
        }else
        {
            priceWithSale.isHidden = true
            
        }
        if (MyVriables.currentGroup?.group_tools?.payments!)! == false
        {
            self.groupAppView.isHidden = false
            self.filterTwo.isHidden = true
            self.filterThree.isHidden = true
        }else{
            if (MyVriables.currentGroup?.rotation) != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
                self.groupAppView.isHidden = true
                self.filterTwo.isHidden = true
                self.filterThree.isHidden = false
            }else{
                self.groupAppView.isHidden = true
                self.filterTwo.isHidden = false
                self.filterThree.isHidden = true
            }
           // self.bookNowView.isHidden = false
        }
        SwiftEventBus.onMainThread(self, name: "roleChanges") { result in
            self.setAlphaView()
            self.member_status_lbl.text = self.tabBarController?.tabBar.items![1].title
            self.member_Status_Im.image = self.tabBarController?.tabBar.items![1].image
            self.footerImage.image = self.tabBarController?.tabBar.items![1].image
            self.footerLabel.text = self.tabBarController?.tabBar.items![1].title
        }
        self.footerImage.image = self.tabBarController?.tabBar.items![1].image
        self.footerLabel.text = self.tabBarController?.tabBar.items![1].title
        member_status_lbl.text = self.tabBarController?.tabBar.items![1].title
        member_Status_Im.image = self.tabBarController?.tabBar.items![1].image
        if (self.tabBarController?.tabBar.items![1].title?.lowercased().contains("closed"))!{
            member_status_view.backgroundColor = UIColor.clear
            
        }
        groupLeaderView.addTapGestureRecognizer {
          self.performSegue(withIdentifier: "showGroupLeader", sender: self)
        }
        member_status_view.addTapGestureRecognizer {
            setCheckTrue(type: "interested", groupID: (MyVriables.currentGroup?.id)!)
            self.tabBarController?.selectedIndex = 1
        }
        self.singleGroup  = MyVriables.currentGroup!
//        titleLabel.text = singleGroup?.title
        if singleGroup?.translations?.count != 0 {
             groupTitleLb.text = singleGroup?.translations?[0].title
            descriptionLbl.text = singleGroup?.translations?[0].description

        }else{
            if singleGroup?.title != nil {
              groupTitleLb.text = singleGroup?.title
            }
            if singleGroup?.description != nil {
                groupTitleLb.text = singleGroup?.description
            }
        }

        setGroupLeader()

        setTripTimeDuration(startDate: (singleGroup?.start_date)!, endDate: (singleGroup?.end_date)!)
        self.descriptionLbl.numberOfLines = 3
        
       
        if singleGroup?.registration_end_date != nil{
            calculateRegisterDate(date: (singleGroup?.registration_end_date)!)
        }else {
            calculateRegisterDate(date: (singleGroup?.start_date)!)
        }
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.circular = false
        slideShow.zoomEnabled = true
        slideShow.isMultipleTouchEnabled = false
        slideShow.contentScaleMode = .scaleAspectFill
        
        slideShow.pageControlPosition = .insideScrollView
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        getGroupImages()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
         startTimer()
        
    }
    @IBAction func showMap(_ sender: Any) {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainMapViewController") as! MainMapViewController
            self.navigationController?.pushViewController(vc,animated: true)
        
    }

    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        counterLbl.text = "\(timeFormatted1(totalSeconds: totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    func timeFormatted1(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    func endTimer() {
        countdownTimer.invalidate()
    }
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            googleMaps.preservesSuperviewLayoutMargins = false
        } else {
            googleMaps.preservesSuperviewLayoutMargins = true
        }
        
        googleMaps.settings.myLocationButton = false
        googleMaps.isMyLocationEnabled = false
        self.googleMaps.delegate = self
        self.googleMaps.settings.accessibilityLanguage = "en"
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        self.googleMaps.isUserInteractionEnabled = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        setAlphaView()
         if (MyVriables.currentGroup?.rotation) != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
            frequency.text = MyVriables.currentGroup?.frequency != nil ? "\((MyVriables.currentGroup?.frequency)!.capitalizingFirstLetter()) Tour": ""
            if MyVriables.currentGroup?.hours_of_operation != nil {
                  timeRecurrnig.text = (MyVriables.currentGroup?.hours_of_operation)!
            }else {
                  timeRecurrnig.text = ""
            }
            timeView.isHidden = true
            reccuring_group.isHidden = false
         }else {
            timeView.isHidden = false
            reccuring_group.isHidden = true
            if MyVriables.currentGroup?.registration_end_date != nil {
                
                
                calculateRegisterDate1( date : (MyVriables.currentGroup?.registration_end_date!)!)
            }else {
                calculateRegisterDate1( date : (MyVriables.currentGroup?.start_date!)!)
            }
        }
       
    }
    func setAlphaView()
    {
        self.singleGroup = MyVriables.currentGroup
        if (self.singleGroup?.role) == nil
        {
            self.membersView.alpha = 0.3
            self.paymentsView.alpha = 0.3
            self.checkListView.alpha = 0.3
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
         if MyVriables.currentGroup?.group_conditions == nil {
            self.rolesView.alpha = 0.3
        }
        if (self.singleGroup?.group_tools?.arrival_confirmation!)! == false
        {
            self.arrivalConfirmView.isHidden = true
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
                self.paymentsView.backgroundColor = Colors.paymentsBacground
                
            }else{
                self.paymentsView.alpha = 0.3
                self.paymentsView.backgroundColor = UIColor.clear
                
            }
            
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
        
        if (self.singleGroup?.group_tools?.arrival_confirmation!)! == false
        {
            self.arrivalConfirmationView.alpha = 0.3
        }
        viewsClick()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.slideShow.currentPageChanged = nil
    }
    //shoeMoreDayDescrption
    @IBAction func ExpandDescriptionTapped(_ sender: Any) {
        if isCollapsed != true {
            self.descriptionLbl.numberOfLines = 0
            self.descriptionLbl.sizeToFit()
            showMoreButton.setTitle("Show Less", for: .normal )
            
        }
        else{
            self.descriptionLbl.numberOfLines = 3
            self.descriptionLbl.lineBreakMode = .byWordWrapping
            self.descriptionLbl.sizeToFit()
            showMoreButton.setTitle("Show More", for: .normal )


        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        
        isCollapsed = !isCollapsed
    }
    
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }
   


    func calculateRegisterDate(date: String){
        if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"
        {
            if MyVriables.currentGroup?.start_time != nil && MyVriables.currentGroup?.end_time != nil {
                self.tripDurationLbl.text = "\(setFormat(date: (MyVriables.currentGroup?.start_time)!)) - \(setFormat(date: (MyVriables.currentGroup?.end_time)!))"
            }else {
                self.tripDurationLbl.text = " "
            }
        }
        else{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("DDDAAATTEEE: "+formatter.string(from: currentDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateFormatter.date(from: date)!
        print("REG END DATE: "+dateFormatter.string(from: date2))
        let days : Int = Calendar.current.dateComponents([.day], from: currentDate, to: date2).day!
        let hours: Int = Calendar.current.dateComponents([.day,.hour,.minute,.month], from: currentDate, to: date2).hour!
        print("days: \(days) , hours: \(hours)")
        if days < 0 || hours < 0 {
            self.tripDurationLbl.text = "Closed"
        }
        else{
            self.tripDurationLbl.text = "\(days) d' \(hours) h'"
        }
        }

    }
    func setGroupLeader(){
        self.groupLeaderNameLbl.text = "\((singleGroup?.group_leader_first_name!)!) \((singleGroup?.group_leader_last_name!)!)"
        groupLeaderImageView.layer.borderWidth = 0
        groupLeaderImageView.layer.masksToBounds = false
        groupLeaderImageView.layer.cornerRadius = groupLeaderImageView.frame.height/2
        groupLeaderImageView.clipsToBounds = true
     //   print(ApiRouts.Web + (singleGroup?.group_leader_image!)!)
       // print(singleGroup?.group_leader_image)
       
        if singleGroup?.group_leader_image != nil{
            var urlString: String = ApiRouts.Media + (singleGroup?.group_leader_image!)!
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: urlString)
            groupLeaderImageView.downloadedFrom(url: url!, contentMode: .scaleToFill)

        }
        if singleGroup?.is_company! != 0 {
            companyLbl.text = (singleGroup?.group_leader_company_name) != nil ? (singleGroup?.group_leader_company_name!)! : ""
            companyDiscrption.text = MyVriables.currentGroup?.group_leader_company_about != nil ? MyVriables.currentGroup?.group_leader_company_about! : ""
            // companyImage.image.url
            
            if MyVriables.currentGroup?.group_leader_company_image != nil {
                var urlString = try ApiRouts.Media + (MyVriables.currentGroup?.group_leader_company_image)!
                print("Url string is \(urlString)")
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                var url = URL(string: urlString)
                if url != nil {
                    self.companyImage.sd_setImage(with: url!, completed: nil)
                }
            }
            else
            {
                self.companyImage.image = UIImage(named: "group tools title")
            }
        }
        else{
            companyLbl.isHidden = true
            companLbl.isHidden = true
            companyView.isHidden = true
            
        }
        
    }
    func setTripTimeDuration(startDate: String, endDate: String){
        if (MyVriables.currentGroup?.rotation) != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"{
            
            
            leftToJoinLbl.text = MyVriables.currentGroup?.translations?[0].destination != nil ? (MyVriables.currentGroup?.translations?[0].destination)! : ""
        }
        else {
        let startMonth: String = self.getMonthName(month: startDate[5...6])
        let endMonth: String = self.getMonthName(month: endDate[5...6])
        let startDay: String = startDate[8...9]
        let endDay: String = endDate[8...9]
        if startMonth == endMonth {
            if startDay == endDay{
                leftToJoinLbl.text = "One day"
            }
            else{
              //  tripDurationLbl.text = startDay+" "+startMonth + "-" + endDay+" "+endMonth
                leftToJoinLbl.text = startDay+"-" + endDay+" "+endMonth

            }
            

        }else{
            leftToJoinLbl.text = startDay+"'"+startMonth + " - " + endDay+"'"+endMonth
        }
        }
    
    }
    func viewsClick() {
        //GroupChatViewController
        //MembersViewController
        //MainMapViewController
        //RolesViewController
        //NewDocsViewController
        //GroupChatViewController
        //ArrivleConfirmationViewController
        membersView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.members!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                    
                }
            }
            
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
            if MyVriables.currentGroup?.group_conditions != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "RolesViewController") as! RolesViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
            
        }
        mapsView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.map!)! == true
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainMapViewController") as! MainMapViewController
                self.navigationController?.pushViewController(vc,animated: true)
               //MainMapViewController
                
            }
            
        }
        docsView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.documents!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                   
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "NewDocsViewController") as! NewDocsViewController
                    self.navigationController?.pushViewController(vc,animated: true)
           
                  
                }
                
            }
            
            
        }
        groupChatView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.chat!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                   //GroupChatViewController self.performSegue(withIdentifier: "showChatGroup", sender: self)
                }
                
            }
            
            
        }
        checkListView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.checklist!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CheckListViewController") as! CheckListViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            }
            
            
        }
        arrivalConfirmationView.addTapGestureRecognizer {
            if (self.singleGroup?.group_tools?.arrival_confirmation!)! == true
            {
                if (self.singleGroup?.role) != nil && (self.singleGroup?.role)! != "observer"
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ArrivleConfirmationViewController") as! ArrivleConfirmationViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                    
                    
                }
            }
        }
    }
    func calculateRegisterDate1(date: String)
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickerData[row]
        }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return planDays.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return  60
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row is \(row)")
        
        if currnetIndex < row {
            self.overView.slideInFromLeft(type: "")
            self.setDayInfo(index: row)
        }else {
            self.overView.slideInFromLeft(type: "asd")
            self.setDayInfo(index: row)
        }
        currnetIndex = row
      
        //bmoPageViewer.presentedPageIndex  = row
    }
    func setHiddenServices(indexDay: Int) {
        self.currentDay = self.planDays[indexDay]
       // self.planDays[index].day_number
        if self.currentDay?.activities?.count == 0 {
            activitiesView.isHidden = true
        }
        else{
            activitiesView.isHidden = false
            var str: String = ""
            for act in (self.currentDay?.activities!)! {
                str.append("\((describing: act.name!)) ")
            }
            activitiesLbl.text = str
        }
        if self.currentDay?.restaurants?.count == 0 {
            restaurantView.isHidden = true
        }else{
            restaurantView.isHidden = false
            var str: String = ""
            for (i,act) in (self.currentDay?.restaurants!)!.enumerated() {
                if i !=  ((self.currentDay?.restaurants!)!.count - 1) {
                    str.append("\((act.translations?[0].name!)!) ,")
                }else{
                    str.append("\((act.translations?[0].name!)!)")
                }
            }
            restLabel.text = str
        }
        if self.currentDay?.hotels?.count == 0 {
            hotelsView.isHidden = true
        }else{
            hotelsView.isHidden = false
            var str: String = ""
            for (i,act) in (self.currentDay?.hotels!)!.enumerated() {
                if i !=  ((self.currentDay?.hotels!)!.count - 1) {
                    str.append("\((act.translations?[0].name!)!) ,")
                }else{
                    str.append("\((act.translations?[0].name!)!)")
                }
                
                
            }
            hotelsLabel.text = str
        }
        if self.currentDay?.places?.count == 0 {
            placesViews.isHidden = true
        }else{
            placesViews.isHidden = false
            var str: String = ""
            for (i,act) in (self.currentDay?.places!)!.enumerated() {
                if i !=  ((self.currentDay?.places!)!.count - 1) {
                    str.append("\((describing: act.name!)) ,")
                    
                }else{
                    str.append("\((describing: act.name!))")
                }
                
            }
            placesLbl.text = str
        }
        if self.currentDay?.tour_guides?.count == 0 {
            tourGuideView.isHidden = true
        }else{
            tourGuideView.isHidden = false
            var str: String = ""
            for (i,act) in (self.currentDay?.tour_guides!)!.enumerated() {
                
                if i !=  ((self.currentDay?.tour_guides!)!.count - 1) {
                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!) ,")
                    
                }else{
                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!)")
                }
                
            }
            toursLbl.text = str
        }
        if self.currentDay?.transports?.count == 0 {
            transportsView.isHidden = true
        }else{
            transportsView.isHidden = false
            var str: String = ""
            for (i,act) in (self.currentDay?.transports!)!.enumerated() {
                if i !=  ((self.currentDay?.transports!)!.count - 1) {
                    str.append("\((describing: act.company_name!)) ,")
                    
                }else{
                    str.append("\((describing: act.company_name!))")
                }
            }
            transportsLbl.text = str
        }
        if hotelsView.isHidden == true &&
            transportsView.isHidden == true &&
            tourGuideView.isHidden == true &&
            placesViews.isHidden == true &&
            activitiesView.isHidden == true &&
            restaurantView.isHidden == true {
            self.servicesLabel.isHidden = true
        }
        else{
            self.servicesLabel.isHidden = false
        }
        
            
        
        
    }
    
     func setDayInfo(index: Int) {
        
       
        DispatchQueue.main.async {
             self.currentDay = self.planDays[index]
            self.dayDescrption.numberOfLines = 3
            self.dayDescrption.sizeToFit()
            self.shoeMoreDayDescrption.text = "Show More"
            self.dayNumber.text = "\((self.planDays[index].day_number)!)"
            //  self.dayDescrption.set
            do {
                
                let header: String = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
                if self.planDays[index].description != nil{
                    self.dayDescrption.setHtmlText("\(header)  \((self.planDays[index].description)!)")
                    
                }else {
                    self.dayDescrption.text = "There is no description"
                }
             
            } catch let error{
                print("Eror day \(error)")
                self.dayDescrption.text = "There is no description"
            }
            print("Maxlinght \(self.dayDescrption.calculateMaxLines())")
            if self.dayDescrption.calculateMaxLines() > 3 {
                self.shoeMoreDayDescrption.isHidden = false
            }
            else{
                self.shoeMoreDayDescrption.isHidden = true
            }
            
           
            self.titleGroup.text = "\((self.planDays[index].title != nil ? self.planDays[index].title : "Day 1")!)"
            self.setHiddenServices(indexDay: index)
            if MyVriables.currentGroup?.rotation != nil && (MyVriables.currentGroup?.rotation)! == "reccuring"
            {
                self.dateGroup.text = ""
                // MyVriables.currentGroup.reg
            }else{
                self.dateGroup.text = "\((self.planDays[index].date != nil ? self.planDays[index].date : "")!)"
            }
            if self.planDays[index].images != nil && self.planDays[index].images?.count != 0 {
                var urlString = ApiRouts.Media + (self.planDays[index].images?[0].path)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                var url = URL(string: urlString)
                
                if url != nil{
                    self.interryImageView.sd_setShowActivityIndicatorView(true)
                    self.interryImageView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    self.interryImageView.sd_setImage(with: url!, completed: nil)
                }
                
                
            }
            else{
                 self.interryImageView.image = UIImage(named: "Group Placeholder")
            }
        }
    
    }
    fileprivate func viewsClicked(indexpathDay: Int) {
        //ServiceModalViewController
        //ProviderViewController
        
        restaurantView.addTapGestureRecognizer {

            ProviderInfo.currentProviderName =  "Restaurants"
            if  (self.currentDay?.restaurants?.count)! == 1
            {
                
                ProviderInfo.currentProviderId =  self.currentDay?.restaurants?[0].id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)
                
                

                //                let vc = ServiceModalViewController()
                //                self.present(vc, animated: true, completion: nil)
                
            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.restaurants)!
                //ServiceModalViewController
                //ProviderViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
            
            
        }
        hotelsView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.hotels?.count)!)")
            
            ProviderInfo.currentProviderName =  "Hotels"
            if  (self.currentDay?.hotels?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.hotels?[0].id
                //ServiceModalViewController
                //ProviderViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)

            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.hotels)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
        activitiesView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.activities?.count)!)")
            
            ProviderInfo.currentProviderName =  "Activities"
            if   (self.currentDay?.activities?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.activities?[0].id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)

            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.activities)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
        placesViews.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.places?.count)!)")
            
            ProviderInfo.currentProviderName =  "Places"
            if   (self.currentDay?.places?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.places?[0].id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)

            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.places)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
        transportsView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.transports?.count)!)")
            ProviderInfo.currentProviderName =  "Transport"
            if  (self.currentDay?.transports?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.transports?[0].id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)

            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.transports)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
        tourGuideView.addTapGestureRecognizer {
            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.tour_guides?.count)!)")
            
            ProviderInfo.currentProviderName =  "Tourguides"
            if   (self.currentDay?.tour_guides?.count)! == 1
            {
                ProviderInfo.currentProviderId =  self.currentDay?.tour_guides?[0].id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProviderViewController") as! ProviderViewController
                self.navigationController?.pushViewController(vc,animated: true)

            }
            else
            {
                ProviderInfo.currentServiceDay = (self.currentDay?.tour_guides)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ServiceModalViewController") as! ServiceModalViewController
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
    }
    
    func getDays(){
        HTTP.GET(ApiRouts.Api+"/days/group/\((MyVriables.currentGroup?.id!)!)") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let days:PlanDays  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                self.planDays = days.days!
                DispatchQueue.main.sync {
                    //self.bmoPageViewer.reloadData()
                    self.pickerInterry.reloadAllComponents()
                    self.setDayInfo(index: 0)
                    self.getMap(dayMap: days)
                }
                
            }
            catch let error{
                print(error)
            }
            //    print("opt finished: \(response.description)")
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow  row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.frame = CGRect(x: 0 , y: 0 , width: 60, height: 40)
        let label = UILabel()
        label.numberOfLines = 0
        label.frame = CGRect(x: 0 , y: 0 , width: 60, height: 40)
        //     label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        
        
        
        
        label.textAlignment = .center
        label.font = UIFont(name:"HelveticaNeue-Bold" , size: 12)
        label.text = "Day\n\(self.planDays[row].day_number!)"
        if #available(iOS 11.0, *) {
            label.textColor = UIColor(named: "Primary")
        } else {
            // Fallback on earlier versions
            label.textColor = Colors.PrimaryColor
        }
        label.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )
        
        view.addSubview(label)
        
        return view
        
    }
    func fitAllMarkers() {
        var bounds = GMSCoordinateBounds()
        
        
        print("Location is \(self.markerList.count)")
        //  let path = GMSMutablePath()
        let   path = GMSMutablePath(path: GMSPath())
        
        for marker in self.markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        CATransaction.begin()
        CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)
        // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
        //  self.googleMaps.animate(toViewingAngle: 45)
        self.googleMaps.animate(with: GMSCameraUpdate.fit(bounds))
        CATransaction.commit()
    }
    
    func createMarker(titleMarker: String , lat: CLLocationDegrees, long: CLLocationDegrees, isMemberMap: Bool, dayNumber: String, postion: Int, isMyId : String, j : Int){
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        marker.title = titleMarker
        let DynamicView=UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 50, height: 50)))
            DynamicView.backgroundColor=UIColor.clear
            var imageViewForPinMarker : UIImageView
            imageViewForPinMarker  = UIImageView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 44, height: 50)))
            if isMyId == "first"{
                imageViewForPinMarker.image = UIImage(named:"markerStart")
                
            }
            else{
                if (self.mapDays.count - 1) == postion {
                    imageViewForPinMarker.image = UIImage(named:"markerEnd")
                    
                }else {
                    imageViewForPinMarker.image = UIImage(named:"markerEmpty")
                }
            }
            let text = UILabel(frame:CGRect(origin: CGPoint(x: 2,y :2), size: CGSize(width: 40, height: 30)))
            
            text.text = "\(j + 1)"
            text.textColor = Colors.PrimaryColor
            text.textAlignment = .center
            text.font = UIFont(name: text.font.fontName, size: 15)
            text.textAlignment = NSTextAlignment.center
            imageViewForPinMarker.addSubview(text)
            DynamicView.addSubview(imageViewForPinMarker)
            UIGraphicsBeginImageContextWithOptions(DynamicView.frame.size, false, UIScreen.main.scale)
            DynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            markcon = imageConverted
        marker.accessibilityLabel = "\(isMemberMap)"
        marker.icon = markcon
        marker.snippet = "\(postion)"
        marker.map = googleMaps
        self.markerList.append(marker)
    }
    var markcon: UIImage = UIImage()
    var markerList : [GMSMarker] = []
    var mapDays: [Day] = []
    var memberMap: [MemberStruct] = []
    func getMap(dayMap: PlanDays){
        self.markerList = []
        self.mapDays = []
                let days  = dayMap
                self.mapDays = days.days!
                var index : Int = 1
                var j: Int = 0
                var postion: Int = 0
                var _: Int = 0
                    for day in self.mapDays {
                        for loc in day.locations! {
                            if j == 0 && postion == 0 {
                                self.createMarker(titleMarker: loc.title != nil ? loc.title! : "", lat: CLLocationDegrees((loc.lat! as NSString).floatValue), long: CLLocationDegrees((loc.long! as NSString).floatValue), isMemberMap: false, dayNumber: "Day \(index)", postion: postion, isMyId: "first", j: j)
                            }else {
                                self.createMarker(titleMarker: loc.title != nil ? loc.title! : "", lat: CLLocationDegrees((loc.lat! as NSString).floatValue), long: CLLocationDegrees((loc.long! as NSString).floatValue), isMemberMap: false, dayNumber: "Day \(index)", postion: postion, isMyId: "false", j : j)
                            }
                            j = j + 1
                        }
                        index = index + 1
                        postion = postion + 1
                    }
                    let DynamicView=UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 50, height: 50)))
                    DynamicView.backgroundColor=UIColor.clear
                    var imageViewForPinMarker : UIImageView
                    imageViewForPinMarker  = UIImageView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 44, height: 50)))
                    imageViewForPinMarker.image = UIImage(named:"markerEnd")
                    let text = UILabel(frame:CGRect(origin: CGPoint(x: 2,y :2), size: CGSize(width: 40, height: 30)))
                    print("Postion is \(postion)")
                    text.text = "\(j)"
                    text.textColor = Colors.PrimaryColor
                    text.textAlignment = .center
                    text.font = UIFont(name: text.font.fontName, size: 15)
                    text.textAlignment = NSTextAlignment.center
                    imageViewForPinMarker.addSubview(text)
                    DynamicView.addSubview(imageViewForPinMarker)
                    UIGraphicsBeginImageContextWithOptions(DynamicView.frame.size, false, UIScreen.main.scale)
                    DynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    self.markcon = imageConverted
                    if self.markerList.count != nil && self.markerList.count > 0 {
                    self.markerList[self.markerList.count-1].icon = self.markcon
                    }
                    self.fitAllMarkers()
}
        
  func getMonthName(month: String) -> String{
        switch month {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
        default:
            return "null"
        }
    }
  
}


extension UILabel {
    func calculateMaxLines() -> Int {
        print("view width is \(frame.size.width)")
        let maxSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

 extension UILabel {
    func setHtmlText(_ html: String) {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.font!.fontName); font-size: \(self.font!.pointSize)\">%@</span>" as NSString, html)
        
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        self.attributedText = attrStr
//        if let attributedText = html.attributedHtmlString {
//            self.attributedText = attributedText
//        }
    }
}
extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(type: String, duration: TimeInterval = 0.4, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        if type == ""{
            slideInFromLeftTransition.subtype = kCATransitionFromRight

        }else{
            if type == "down" {
                slideInFromLeftTransition.subtype = kCATransitionFromBottom
            }else {
                if type == "top" {
                    slideInFromLeftTransition.subtype = kCATransitionFromTop
                }else {
                    slideInFromLeftTransition.subtype = kCATransitionFromLeft
                }
            }

        }
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
}

