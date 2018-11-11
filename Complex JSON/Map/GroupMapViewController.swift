//
//  GroupMapViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/15/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftHTTP
import ARSLineProgress
import SocketIO
import TTGSnackbar
import SearchTextField
import ModernSearchBar
import SwiftEventBus
import ISHPullUp



enum Location {
    case startLocation
    case destinationLocation
}
class GroupMapViewController: UIViewController , GMSMapViewDelegate
, CLLocationManagerDelegate, ModernSearchBarDelegate, ISHPullUpContentDelegate{

    
 
    @IBOutlet weak var layoutAnnotationLabel: UILabel!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var filterMap: UIView!
    @IBOutlet weak var googleMapConstrate: NSLayoutConstraint!
    @IBOutlet weak var refreshCountMember: UILabel!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var socketView: UIView!
    @IBOutlet weak var memberMapView: UIView!
    var socket: SocketIOClient?
    var socketManager : SocketManager?
    @IBOutlet weak var tripMapView: UIView!
    @IBOutlet weak var memberMapLine: UIView!
    @IBOutlet weak var tripMemberLine: UIView!
    @IBOutlet weak var meberMapLbl: UILabel!
    @IBOutlet weak var tripMmeberLbl: UILabel!
    @IBOutlet weak var googleMaps: GMSMapView!
    var locationManager =  CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var singleGroup: TourGroup?
    var markcon: UIImage = UIImage()
    var markerList : [GMSMarker] = []
    var mapDays: [Day] = []
    var memberMap: [MemberStruct] = []
    
    @IBOutlet weak var backPressed: UIButton!
    var socketBudjes : Int = 0
    
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    func loadNiB() -> MapMarkerWindow {
        let infoWindow = MapMarkerWindow.instanceFromNib() as! MapMarkerWindow
        return infoWindow
    }
    override func viewWillDisappear(_ animated: Bool) {
        socket?.disconnect()
    }
    

    
    
    
    @IBAction func filterClick(_ sender: Any) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutAnnotationLabel.layer.cornerRadius = 2;
        if #available(iOS 11.0, *) {
            googleMaps.preservesSuperviewLayoutMargins = false
        } else {
            googleMaps.preservesSuperviewLayoutMargins = true
        }
        
        self.modernSearchBar.delegateModernSearchBar = self
        SwiftEventBus.onMainThread(self, name: "GoToPrivateChat") { result in
            self.performSegue(withIdentifier: "privateChatSegue", sender: self)
        }
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        memberMapView.addTapGestureRecognizer {
           
            if isLogged == true{
                if MyVriables.currentGroup?.role != nil{
                    if MyVriables.currentGroup?.role! == "member" || MyVriables.currentGroup?.role! == "group_leader"
                    {
                        SwiftEventBus.post("removeFilter")
                        self.sendFcm()
                        self.memberMapLine.backgroundColor = Colors.PrimaryColor
                        //self.filterMap.isHidden = true
                        self.meberMapLbl.textColor = Colors.PrimaryColor
                        self.tripMemberLine.backgroundColor = UIColor.white
                        self.tripMmeberLbl.textColor = Colors.grayDarkColor
                        self.googleMaps.clear()
                        self.setMemberLocaion()
                        self.googleMapConstrate.constant = 56
                    }
                    else{
                        let snackbar = TTGSnackbar(message: "You must be join to the group to see members map", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                }
                else{
                    let snackbar = TTGSnackbar(message: "You must be join to the group to see members map", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                
            }else{
                let snackbar = TTGSnackbar(message: "You must be join to the group to see members map", duration: .middle)
                snackbar.icon = UIImage(named: "AppIcon")
                snackbar.show()
            }
           
            

        }
        self.refreshView.addTapGestureRecognizer {
            if isLogged == true{
                if MyVriables.currentGroup?.role != nil{
                    if MyVriables.currentGroup?.role! == "member" || MyVriables.currentGroup?.role! == "group_leader"
                    {
            SwiftEventBus.post("removeFilter")
            self.memberMapLine.backgroundColor = Colors.PrimaryColor
            self.meberMapLbl.textColor = Colors.PrimaryColor
            self.tripMemberLine.backgroundColor = UIColor.white
            self.tripMmeberLbl.textColor = Colors.grayDarkColor
            self.googleMaps.clear()
            self.socketBudjes = 0
            self.setMemberLocaion()
            
            self.setView(view: self.socketView, hidden: true)
            
            self.googleMapConstrate.constant = 56
                    }
                }
            }
        }
        //sendFcm
//        self.infoWindow = loadNiB()
        tripMapView.addTapGestureRecognizer {
            SwiftEventBus.post("insertFilter")
            self.googleMapConstrate.constant = 0
            self.tripMemberLine.backgroundColor = Colors.PrimaryColor
            self.tripMmeberLbl.textColor = Colors.PrimaryColor
            self.memberMapLine.backgroundColor = UIColor.white
            self.meberMapLbl.textColor = Colors.grayDarkColor
            self.googleMaps.clear()
            print("get days before")
            self.markerList = []
           // self.filterMap.isHidden = false

            self.getDays()
            
            
            print("get days after")

            
        }
      
        
        // MAP INITIATION
 
        
      
       

         getDays()
        
        // use bounds
    }
    func onClickItemWithUrlSuggestionsView(item: ModernSearchBarModel) {
          print("User touched this item: "+item.title+" with this url: "+item.url.description + " and postion is \(item.postion)")
        self.modernSearchBar.closeSuggestionsView()
        self.modernSearchBar.delegateModernSearchBar?.searchBarCancelButtonClicked?(self.modernSearchBar)
        self.modernSearchBar.endEditing(true)
        
        self.modernSearchBar.text = ""
      
            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)

        
            self.googleMaps.animate(toViewingAngle: 45)
        self.googleMaps.animate(toZoom: 10)
            self.googleMaps.animate(toLocation:      CLLocationCoordinate2DMake(CLLocationDegrees((self.memberMap[item.postion!].lat! as NSString).floatValue), CLLocationDegrees((self.memberMap[item.postion!].lon! as NSString).floatValue)))
            
            CATransaction.commit()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees((self.memberMap[item.postion!].lat! as NSString).floatValue), CLLocationDegrees((self.memberMap[item.postion!].lon! as NSString).floatValue))
        marker.title = item.title!

        markcon = resizeImage(image: UIImage(named: "MyMarker")!, targetSize: CGSize(width: 44.0, height: 50.0))
        
        marker.accessibilityLabel = "\(true)"
        marker.icon = markcon
        marker.snippet = "\(item.postion!)"
        marker.map = googleMaps
        self.googleMaps.selectedMarker = marker
  
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSocket()
        googleMaps.settings.myLocationButton = false
        googleMaps.isMyLocationEnabled = false
        self.googleMaps.delegate = self
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
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
    
    
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print("im clicked")
    }
    
    func createMarker(titleMarker: String , lat: CLLocationDegrees, long: CLLocationDegrees, isMemberMap: Bool, dayNumber: String, postion: Int, isMyId : String, j : Int){
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        marker.title = titleMarker
        
        if isMemberMap == true
        {
         
            if isMyId == "true"
            {
                    markcon = UIImage(named: "mylocation")!
            }
            else {
                   markcon = UIImage(named: "membersMarkers")!
            }
        }else{
            print("Count is \((self.mapDays.count - 1)) and postion is \(postion)")

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
        }
        marker.accessibilityLabel = "\(isMemberMap)"
        marker.icon = markcon
        marker.snippet = "\(postion)"
        marker.map = googleMaps
        self.markerList.append(marker)
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("in did tap function \(marker.title)")
        return false
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print("index is \(marker.title)")

        if marker.accessibilityLabel == "false" {
        let customInfoWindow = UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! MapMarkerWindow
            var dayNumber:Int? = Int(marker.snippet!)! + 1
            customInfoWindow.dayNumber.text = "Day \((dayNumber!))"
            customInfoWindow.locationName.text = marker.title!
            customInfoWindow.viewclick.addTapGestureRecognizer {
                print("Im clicked here")
                self.openWaze(location: marker.position)

            }
            return customInfoWindow
        }
        else
        {
        let customInfoWindow = UINib(nibName: "MemberMapView", bundle: nil).instantiate(withOwner: self, options: nil).first as! MemberMapView
        customInfoWindow.memberName.text = marker.title!
            customInfoWindow.lastSeen.text = self.memberMap[Int(marker.snippet!)!].updated_at != nil ? self.memberMap[Int(marker.snippet!)!].updated_at! : ""
            if self.memberMap[Int(marker.snippet!)!].profile_image != nil
            {
                let urlString = try ApiRouts.Web + (self.memberMap[Int(marker.snippet!)!].profile_image!)
                var url = URL(string: urlString)
                print("Url string is \(urlString)")
                if url == nil {

                }else {
                    customInfoWindow.memberImage.sd_setImage(with: url, completed: nil)
                }
            }


        return customInfoWindow
        }

    }
    
    var tappedMarker = GMSMarker()
    var infoWindow = MapMarkerWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("clicked \(marker.title)")
        if marker.accessibilityLabel == "false" {
            
            openWaze(location: marker.position)
            
        }
        else
        {
            var currentMemmber: GroupMember? = GroupMember(id : self.memberMap[Int(marker.snippet!)!].member_id, email : "", first_name : self.memberMap[Int(marker.snippet!)!].first_name != nil ? self.memberMap[Int(marker.snippet!)!].first_name! : "", last_name : self.memberMap[Int(marker.snippet!)!].last_name != nil ? self.memberMap[Int(marker.snippet!)!].last_name! : "", profile_image : self.memberMap[Int(marker.snippet!)!].profile_image != nil ? self.memberMap[Int(marker.snippet!)!].profile_image! : nil, companion_number : 0, status : "nil", role : "member")
            GroupMembers.currentMemmber = currentMemmber
            performSegue(withIdentifier: "showMemberModal", sender: self)


        }
    }
    
    func openWaze(location : CLLocationCoordinate2D) {
        print("location is \(location)")
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            print("esm3 ana jwa al aola")
            // Waze is installed. Launch Waze and start navigation
            let urlStr: String = "waze://?ll=\(location.latitude),\(location.longitude)&navigate=yes"
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
        else {
            print("esm3 ana jwa al thanya")

            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.openURL(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
    }
    func sendFcm() {

        HTTP.POST(ApiRouts.Api+"/firebase/send_location/\((MyVriables.currentGroup?.id)!)") { response in
            if let err = response.error {
                ARSLineProgress.hide()
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("response fcm is \(response.description)")
            
        }
    }
    func setMemberLocaion() {
        var currentLocation: CLLocation!
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            currentLocation = locManager.location
            print("Location lat is \(currentLocation.coordinate.longitude) and location long is \(currentLocation.coordinate.latitude)")
            
        
            self.mapDays = []
            self.markerList = []
            ARSLineProgress.show()
            HTTP.POST(ApiRouts.Api+"/members/locations/member/\((MyVriables.currentMember?.id)!)?group_id/\((MyVriables.currentGroup?.id)!)", parameters: ["lat": currentLocation.coordinate.latitude, "lon": currentLocation.coordinate.longitude]) { response in
                if let err = response.error {
                    DispatchQueue.main.async {
                        ARSLineProgress.hide()
                        
                    }
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                print("response is \(response)")
                do{
                    DispatchQueue.main.async {
                        ARSLineProgress.hide()
                        
                    }
                    self.getMemberMap()
                }catch {
                    
                }

            }
            
        }
        else {
            let snackbar = TTGSnackbar(message: "Please allow location permission to display group members real time location on the map", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
    
        }
        
    }
    
    fileprivate func getMembersLocationRequest() -> HTTP? {
        return HTTP.GET(ApiRouts.Api+"/members/locations/group/\((MyVriables.currentGroup?.id)!)") { response in
            if let err = response.error {
                DispatchQueue.main.async {
                    ARSLineProgress.hide()
                    
                }
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                DispatchQueue.main.async {
                    ARSLineProgress.hide()

                }
                ARSLineProgress.hide()
                let days  = try JSONDecoder().decode(MemberMap.self, from: response.data)
                self.memberMap = days.members!
                print("membersDays:")
                print(response.description)
                var index: Int = 1
                var postion: Int = 0
                var suggestionListWithUrl : [ModernSearchBarModel] = []
                var isMyId :Bool = false
                print("members  5 == \(self.memberMap[5].first_name) and 6 == \(self.memberMap[6].first_name)")
                for member in self.memberMap {
                    if member.lat != nil && member.lon != nil {
                        print("Index is \(postion) and member name is \(member.first_name)")
                        if member.profile_image != nil {
                            var urlString: String = try ApiRouts.Web + (member.profile_image)!
                            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                            suggestionListWithUrl.append(ModernSearchBarModel(title: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", url: urlString, postion : postion))
                        }
                        else
                        {
                            var urlString: String = "https://user-images.githubusercontent.com/17565537/42417530-5a8ea9f2-8295-11e8-9323-e3972f008c3f.png"
                            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                            suggestionListWithUrl.append(ModernSearchBarModel(title: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", url: urlString, postion : postion))
                        }
                        //print("my id is = \((MyVriables.currentMember?.id)!) my member is = \((member.member_id)!) member name is \((member.first_name)!)")
                        if (MyVriables.currentMember?.id)! == (member.member_id)!{
                            self.createMarker(titleMarker: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", lat: CLLocationDegrees((member.lat! as NSString).floatValue), long: CLLocationDegrees((member.lon! as NSString).floatValue), isMemberMap: true, dayNumber: "", postion: postion, isMyId: "true", j: postion)
                        }
                        else {
                            self.createMarker(titleMarker: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", lat: CLLocationDegrees((member.lat! as NSString).floatValue), long: CLLocationDegrees((member.lon! as NSString).floatValue), isMemberMap: true, dayNumber: "", postion: postion, isMyId: "false", j: postion)
                        }
                        index = index + 1
                        postion = postion + 1
                    }
                    else
                    {
                        
                    }
                }
                print("suggestionListWithUrl \((suggestionListWithUrl.count)) and htte index is \(self.memberMap.count)")
                DispatchQueue.main.async {
                    self.modernSearchBar.setDatasWithUrl(datas: suggestionListWithUrl)
                    ARSLineProgress.hide()
                    self.fitAllMarkers()
                }
                
                
                
            }
            catch let error{
                print("error is \(error)")
                ARSLineProgress.hide()
                print(error)
            }
        }
    }
    
    func getMemberMap(){
        self.memberMap = []
        self.markerList = []
        
       // print("Url is " + ApiRouts.Web+"/api/members/locations/group/\((MyVriables.currentGroup?.id)!)")
        HTTP.GET(ApiRouts.Api+"/members/locations/group/\((MyVriables.currentGroup?.id)!)") { response in
            if let err = response.error {
                ARSLineProgress.hide()
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let days  = try JSONDecoder().decode(MemberMap.self, from: response.data)
                self.memberMap = days.members!
                print("membersDays :--")
                print(response.description)
                var index: Int = 1
                var postion: Int = 0
                var suggestionListWithUrl : [ModernSearchBarModel] = []
                try DispatchQueue.main.sync {
                    for member in self.memberMap {
                        if member.lat != nil && member.lon != nil {
                            if member.profile_image != nil {
                                let urlString: String = try ApiRouts.Web + (member.profile_image)!
                                suggestionListWithUrl.append(ModernSearchBarModel(title: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", url: urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, postion : postion))
                            }
                            else
                            {
                                var urlString: String = "https://user-images.githubusercontent.com/17565537/42417530-5a8ea9f2-8295-11e8-9323-e3972f008c3f.png"
                                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                                suggestionListWithUrl.append(ModernSearchBarModel(title: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", url: urlString, postion : postion))
                            }
                            if (MyVriables.currentMember?.id)! == (member.member_id)!{
                                self.createMarker(titleMarker: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", lat: CLLocationDegrees((member.lat! as NSString).floatValue), long: CLLocationDegrees((member.lon! as NSString).floatValue), isMemberMap: true, dayNumber: "", postion: postion, isMyId: "true", j: postion)
                            }
                            else {
                                self.createMarker(titleMarker: member.first_name != nil && member.last_name != nil ? "\(member.first_name!) \(member.last_name!)" : "User \(member.member_id!)", lat: CLLocationDegrees((member.lat! as NSString).floatValue), long: CLLocationDegrees((member.lon! as NSString).floatValue), isMemberMap: true, dayNumber: "", postion: postion, isMyId: "false", j: postion)
                            }
                            index = index + 1
                            postion = postion + 1
                        }
                    }
                    self.modernSearchBar.setDatasWithUrl(datas: suggestionListWithUrl)
                    ARSLineProgress.hide()
                    self.fitAllMarkers()
                }
            }
            catch let error{
                print("error is \(error)")
               
            }
        }
        
        
//        getMembersLocationRequest()
    }
    func setView(view: UIView, hidden: Bool) {
       
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
      
    }

    func getDays(){
        self.markerList = []
        self.mapDays = []
        ARSLineProgress.show()
        print("Url == " + ApiRouts.Web+"/api/days/group/\((MyVriables.currentGroup?.id)!)")
        HTTP.GET(ApiRouts.Api+"/days/group/\((MyVriables.currentGroup?.id)!)") { response in
            if let err = response.error {
                ARSLineProgress.hide()
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let days  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                self.mapDays = days.days!
                var index : Int = 1
                var j: Int = 0
                var postion: Int = 0
                var count: Int = 0
                DispatchQueue.main.sync {
                    
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
                    ARSLineProgress.hide()
                    self.fitAllMarkers()
                }

            }
            catch let error{
                ARSLineProgress.hide()
                print(error)
            }
        }
    }
    
    func setSocket(){
        
        print("----- Hosen -----")
        var  manager = SocketManager(socketURL: URL(string: ApiRouts.ChatServer)!, config: [.log(true),.forcePolling(true)])
        socket = manager.defaultSocket
        //"group-chat-"+groupId+":chat-message"
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket!.emit("subscribe", "group-\((MyVriables.currentGroup?.id)!)")
        }
        socket!.on("group-\((MyVriables.currentGroup?.id)!):send-member-location")
        { data, ack in
            print("im in on recive")
           // print("onMessageRec: \(data[0])")
            if let data2 = data[0] as? Dictionary<String, Any> {
                if let messageClass = data2["member_location"] as? Dictionary<String, Any> {
                    var MEMBER_Idd : Int?
                    MEMBER_Idd = messageClass["member_id"] as? Int
                  print("im in on message my id \((MyVriables.currentMember?.id)!) and there member id \((MEMBER_Idd)!)")
                    if ((MyVriables.currentMember?.id)! != (MEMBER_Idd)!)
                    {
                        self.socketBudjes = self.socketBudjes + 1
                    }
                    print("Budges is \(self.socketBudjes)")

                    if self.socketBudjes != 0
                    {
                        print("Budges is \(self.tripMemberLine.backgroundColor) and color is \(Colors.PrimaryColor)")

                        self.refreshCountMember.text = "\(self.socketBudjes) Members updated"
                        if self.googleMapConstrate.constant == 56{
                        self.setView(view: self.socketView, hidden: false)
                        }
                    }
//                    else
//                    {
//                        self.setView(view: self.socketView, hidden: false)
//                    }
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
    

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController contentVC: UIViewController) {
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = edgeInsets
            rootView.layoutMargins = .zero
        } else {
            // update edgeInsets
            rootView.layoutMargins = edgeInsets
        }
        
        // call layoutIfNeeded right away to participate in animations
        // this method may be called from within animation blocks
        rootView.layoutIfNeeded()
    }
    
    

}
extension UIImageView {
    
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
}
