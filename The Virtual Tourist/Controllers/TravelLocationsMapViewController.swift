//
//  ViewController.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 11/03/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private var longTapGesture = UILongPressGestureRecognizer()
    
    private let appDelegateObj = UIApplication.shared.delegate as! AppDelegate
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<LocationPinTable>!
    
    var locationPinTableObj: LocationPinTable?
    
    fileprivate func setupFetchedResultController(){
        let fetchRequest: NSFetchRequest<LocationPinTable> = LocationPinTable.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "LocationPins")
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("Fetch action could not be performed : \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataController = appDelegateObj.dataController
        mapView.delegate = self
        
//                requestLocationPermission()
//                requestLiveCurrentLocationDetailsWithAccuracy()
        
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressPinLocation))
        longTapGesture.minimumPressDuration = 1
        
        mapView.addGestureRecognizer(longTapGesture)
        
        setupFetchedResultController()
        
        fetchLocallyStoredLocationPins()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
    }
    
    func fetchLocallyStoredLocationPins(){
        let dbLocationsObjects = fetchedResultsController.fetchedObjects

        if let pins = dbLocationsObjects {
            for pin in pins {
                print("location pin coordinates : \(pin.longitude) / \(pin.latitude)")
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                Utils.markLocation(locationCoordinates: coord, mapView: mapView)
            }
        }
    }
    
    @objc func handleLongPressPinLocation(){
        
        if longTapGesture.state == .ended {
               let point = longTapGesture.location(in: mapView)
               let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            Utils.markLocation(locationCoordinates: coordinate, mapView: mapView)
           insertLocationPinDetails(coordinates: coordinate)
           }
    }
    
    func insertLocationPinDetails(coordinates: CLLocationCoordinate2D){
        locationPinTableObj = LocationPinTable(context: dataController.viewContext)
        locationPinTableObj!.latitude = coordinates.latitude
        locationPinTableObj!.longitude = coordinates.longitude
             appDelegateObj.saveViewContext()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation?.coordinate != nil{
            moveToPhotoAlbum(locationCoordinates: view.annotation!.coordinate)
        }
    }
    
    
    private func moveToPhotoAlbum(locationCoordinates: CLLocationCoordinate2D){
        let photoAlbumViewConteoller = storyboard?.instantiateViewController(withIdentifier: "Photo Album") as! PhotoAlbumViewController
        
        photoAlbumViewConteoller.travelLocationCoordinates = locationCoordinates
        photoAlbumViewConteoller.dataController = dataController
        photoAlbumViewConteoller.location = locationPinTableObj!
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
}

