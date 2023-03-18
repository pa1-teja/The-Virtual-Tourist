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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    var travelLocationCoordinates: [TravelLocationModel.travelLocation]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var LoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noPhotosAlertLabel: UILabel!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var photosList:[FlickrAPIResponseModel.Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingIndicator.isHidden = true
       
        
        noPhotosAlertLabel.isHidden = true
        for i in (0 ..< travelLocationCoordinates.count){
            Utils.markLocation(locationCoordinates: travelLocationCoordinates[i].locationCoordinates, mapView: mapView)
        }
        
        var url = FlickrAPI.FlickrEndpoint.coordinates(String(travelLocationCoordinates[0].locationCoordinates.latitude), String(travelLocationCoordinates[0].locationCoordinates.longitude)).url
        
        
        LoadingIndicator.isHidden = false
        
        GenericAPIInfo.taskInteractWithAPI(isImageLoading: false,methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: FlickrAPIResponseModel.FlickrAPIResponse.self, completionHandler: handleFlickrAPIPhotosResponse(success:error:))
    }
    
    
    func handleFlickrAPIPhotosResponse(success: FlickrAPIResponseModel.FlickrAPIResponse?, error: Error?){
        
        LoadingIndicator.isHidden = true
        
        guard let success = success else{
            print("FLICKR API GET response failed : \(error?.localizedDescription)")
            return
        }
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        var response = FlickrAPIResponseModel.FlickrAPIResponse.init(photos: success.photos, stat: success.stat)
        photosList = response.photos.photo
        photosCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flickr Photo", for: indexPath) as! TravelPhotosCollectionViewCell
        
        let url = FlickrAPI.getFlickrImageURL(serverId: photosList![(indexPath as NSIndexPath).row].server, imageId: photosList![(indexPath as NSIndexPath).row].id, imageSecret: photosList![(indexPath as NSIndexPath).row].secret)
        
        DispatchQueue.global().async {
//            GenericAPIInfo.taskInteractWithAPI(isImageLoading: true, methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: UIImage.self, completionHandler: handleFetchedFlickrImage(fetchedImage:error:))
            
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async {
                    cell.photoViewCell.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func handleFetchedFlickrImage(fetchedImage:UIImage?, error: Error?){
        
    }
    

}
