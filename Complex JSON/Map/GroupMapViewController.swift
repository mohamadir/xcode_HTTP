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
enum Location {
    case startLocation
    case destinationLocation
}
class GroupMapViewController: UIViewController , GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var googleMaps: GMSMapView!
    var locationManager =  CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var singleGroup: TourGroup?
    var markcon: UIImage = UIImage()
    var markerList : [GMSMarker] = []
    var mapDays: [Day] = []
    @IBOutlet weak var backPressed: UIButton!
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.singleGroup  = MyVriables.currentGroup!
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        // MAP INITIATION
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        
        
        // MARKER ICON
        markcon = resizeImage(image: UIImage(named: "member marker")!, targetSize: CGSize(width: 44.0, height: 50.0))
       
        
        // ADD MARKERS TO MAP
//        self.createMarker(titleMarker: "Jerusalem",iconMarker: markcon , lat:  31.771959, long: 35.217018)
//        self.createMarker(titleMarker: "Tel Aviv",iconMarker: markcon, lat:  32.109333, long: 34.855499)
//        self.createMarker(titleMarker: "Jerusalem",iconMarker: markcon , lat:  29.55805, long: 34.94821)
//         self.createMarker(titleMarker: "Cairo",iconMarker: markcon , lat:  30.044281, long: 31.340002)
         getDays()
        
        // use bounds
    }

    func fitAllMarkers() {
        var bounds = GMSCoordinateBounds()
        
        for marker in markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        googleMaps.animate(with: GMSCameraUpdate.fit(bounds))
    }
    func createMarker(titleMarker: String , iconMarker: UIImage, lat: CLLocationDegrees, long: CLLocationDegrees){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        marker.title = title
        marker.icon = iconMarker
        self.markerList.append(marker)
        marker.map = googleMaps
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
    
    func getDays(){
        ARSLineProgress.show()
        HTTP.GET(ApiRouts.Web+"/api/days/group/\((self.singleGroup?.id!)!)") { response in
            if let err = response.error {
                ARSLineProgress.hide()
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let days  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                self.mapDays = days.days!
                DispatchQueue.main.sync {
                    for day in self.mapDays {
                        for loc in day.locations! {
                            self.createMarker(titleMarker: loc.title!, iconMarker: self.markcon, lat: CLLocationDegrees((loc.lat! as NSString).floatValue), long: CLLocationDegrees((loc.long! as NSString).floatValue))
                        }
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


}
