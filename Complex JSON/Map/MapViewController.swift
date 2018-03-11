//
//  MapViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
class MapViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapViewController: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let target = CLLocationCoordinate2D(latitude: -33.868, longitude: 151.208)
//        mapViewController.camera = GMSCameraPosition.camera(withTarget: target, zoom: 6)
        // Do any additional setup after loading the view.
    }


}
