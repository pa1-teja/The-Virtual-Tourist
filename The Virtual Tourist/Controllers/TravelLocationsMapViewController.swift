//
//  ViewController.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 11/03/23.
//

import UIKit
import MapKit
import CoreLocation


class TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private var longTapGesture = UILongPressGestureRecognizer()
    
    private let locationObj = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
                requestLocationPermission()
                requestLiveCurrentLocationDetailsWithAccuracy()
        
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressPinLocation))
        longTapGesture.minimumPressDuration = 1
        
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @objc func handleLongPressPinLocation(){
        
        if longTapGesture.state == .ended {
               let point = longTapGesture.location(in: mapView)
               let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            Utils.markLocation(locationCoordinates: coordinate, mapView: mapView)
           }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation?.coordinate != nil{
            locationObj.location.append(TravelLocationModel.travelLocation.init(locationCoordinates: view.annotation!.coordinate))
            moveToPhotoAlbum(locationCoordinates: locationObj.location)
        }
    }
    
    
    private func moveToPhotoAlbum(locationCoordinates: [TravelLocationModel.travelLocation]){
        let photoAlbumViewConteoller = storyboard?.instantiateViewController(withIdentifier: "Photo Album") as! PhotoAlbumViewController
        
        photoAlbumViewConteoller.travelLocationCoordinates = locationCoordinates
        
        navigationController?.pushViewController(photoAlbumViewConteoller, animated: true)
    }
    
    private func requestLocationPermission(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func isLocationServicesEnabled() -> Bool{
        var isEnabled: Bool = false
        DispatchQueue.main.async {
            isEnabled = CLLocationManager.locationServicesEnabled()
        }
        return isEnabled
    }
    
    private func requestLiveCurrentLocationDetailsWithAccuracy(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(manager.location != nil){
            Utils.pinLocationOnMap(locationManager: manager,mapView: self.mapView)
        }
    }
    

    
    func onMapLoad(){
        
        
       
    }
    
    func onLocationLogPressDetected(){
//        let annotation = MKPointAnnotation()
//        let location = CLLocationCoordinate2D(latitude: profile.latitude, longitude: profile.longitude)
//        annotation.coordinate = location
//        annotation.title = profile.firstName
//        annotation.subtitle = profile.mediaURL
//
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//
//        let region = MKCoordinateRegion(center: location, span: span)
//
//        mapView.setRegion(region, animated: false)
//        mapView.addAnnotation(annotation)
    }
    

}

