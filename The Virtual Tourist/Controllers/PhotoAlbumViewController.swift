//
//  PhotoAlbumViewController.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 11/03/23.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class PhotoAlbumViewController: UIViewController{

    
    var travelLocationCoordinates: [TravelLocationModel.travelLocation]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in (0 ..< travelLocationCoordinates.count){
            Utils.markLocation(locationCoordinates: travelLocationCoordinates[i].locationCoordinates, mapView: mapView)
        }
    }
}
