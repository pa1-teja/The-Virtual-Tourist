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
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{

    
    var travelLocationCoordinates: CLLocationCoordinate2D!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<PhotosTable>!
    
    var location:LocationPinTable?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var LoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noPhotosAlertLabel: UILabel!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var photosList:[FlickrAPIResponseModel.Photo]?
    
    fileprivate func setupFetchedResultController(){
        let fetchRequest: NSFetchRequest<PhotosTable> = PhotosTable.fetchRequest()
        
        let location = LocationPinTable(context: dataController.viewContext)
        location.latitude = travelLocationCoordinates.latitude
        location.longitude = travelLocationCoordinates.longitude
        
        let predicate = NSPredicate(format: "latitude == %@", String(travelLocationCoordinates.latitude))
        
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "PhotosCache")
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("Fetch action could not be performed : \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingIndicator.isHidden = false
       
        
        noPhotosAlertLabel.isHidden = true
        
            Utils.markLocation(locationCoordinates: travelLocationCoordinates, mapView: mapView)
        
        location = LocationPinTable(context: dataController.viewContext)
        location?.longitude = travelLocationCoordinates.longitude
        location?.latitude = travelLocationCoordinates.latitude
        
        setupFetchedResultController()
        
       
        
        LoadingIndicator.isHidden = false
        
        if(fetchedResultsController.fetchedObjects!.isEmpty){
            var url = FlickrAPI.FlickrEndpoint.coordinates(String(travelLocationCoordinates.latitude), String(travelLocationCoordinates.longitude)).url
            GenericAPIInfo.taskInteractWithAPI(isImageLoading: false,methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: FlickrAPIResponseModel.FlickrAPIResponse.self, completionHandler: handleFlickrAPIPhotosResponse(success:error:))
        } else{
            LoadingIndicator.isHidden = true
            photosCollectionView.delegate = self
            photosCollectionView.dataSource = self
            photosCollectionView.reloadData()
        }
        
        print("databse photos count: \(fetchedResultsController.fetchedObjects?.count)")
        
        for photo in fetchedResultsController.fetchedObjects! {
            print("in photos table  latitude : \(photo.latitude)  / logitude : \(photo.longitude)")
        }
    }
    
    private func insertPhotosToDB(imageData: Data){
        let photoTable = PhotosTable(context: dataController.viewContext)
        photoTable.photo = imageData
        photoTable.longitude = travelLocationCoordinates.longitude as Double
        photoTable.latitude = travelLocationCoordinates.latitude as Double
        do{
            try dataController.viewContext.save()
            print("photo insertion succesful")
        }catch{
            print("Photo insetion into DB failed due to : \(error.localizedDescription)")
        }
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
        if(fetchedResultsController.fetchedObjects!.isEmpty){
            return photosList!.count
        }else{
            return fetchedResultsController.fetchedObjects!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flickr Photo", for: indexPath) as! TravelPhotosCollectionViewCell
        
        if(fetchedResultsController.fetchedObjects!.isEmpty){
            
            let url = FlickrAPI.getFlickrImageURL(serverId: photosList![(indexPath as NSIndexPath).row].server, imageId: photosList![(indexPath as NSIndexPath).row].id, imageSecret: photosList![(indexPath as NSIndexPath).row].secret)
            
            DispatchQueue.global().async {
                //            GenericAPIInfo.taskInteractWithAPI(isImageLoading: true, methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: UIImage.self, completionHandler: handleFetchedFlickrImage(fetchedImage:error:))
                
                if let data = try? Data(contentsOf: url){
                    DispatchQueue.main.async {
                        cell.photoViewCell.image = UIImage(data: data)
                    }
                    self.insertPhotosToDB(imageData: data)
                }
            }
        }else{
            DispatchQueue.main.async {
                cell.photoViewCell.image = UIImage(data: self.fetchedResultsController.fetchedObjects![(indexPath as NSIndexPath).row].photo!)
            }
        }
        
        return cell
    }

}
