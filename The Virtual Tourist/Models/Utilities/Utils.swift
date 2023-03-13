//
//  Utils.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 12/03/23.
//

import Foundation
import CoreLocation
import MapKit


class Utils{

    
   class func pinLocationOnMap(locationManager: CLLocationManager!, mapView:MKMapView!){
        
        let lat = locationManager.location?.coordinate.latitude
        let lng = locationManager.location?.coordinate.longitude
        
        switch locationManager.authorizationStatus{
            
        case .authorizedAlways: markLocation(locationCoordinates: locationManager.location!.coordinate, mapView: mapView)
            return
        case .authorizedWhenInUse: markLocation(locationCoordinates: locationManager.location!.coordinate, mapView: mapView)
            return
        case .denied: return
        case .restricted: return
        case .notDetermined: return
        default : return
        }
    }
    
    
     class func markLocation(locationCoordinates: CLLocationCoordinate2D, mapView: MKMapView!){
        
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: locationCoordinates.latitude , longitude: locationCoordinates.longitude)
        annotation.coordinate = location
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation)
    }
}
