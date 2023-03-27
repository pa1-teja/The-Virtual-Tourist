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
    
    @IBOutlet weak var newFlickrCollectionPhotos: UIButton!
    
    
    var photosList:[FlickrAPIResponseModel.Photo]?
    
    @IBAction func discardAndGetFreshPhotos(_ sender: Any) {
        
    }
    
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
        
        
        
            Utils.markLocation(locationCoordinates: travelLocationCoordinates, mapView: mapView)
        
        location = LocationPinTable(context: dataController.viewContext)
        location?.longitude = travelLocationCoordinates.longitude
        location?.latitude = travelLocationCoordinates.latitude
        
        setupFetchedResultController()
        
        let photoLongTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoLongPressDeletion(longPress:)))
        photoLongTapGesture.minimumPressDuration = 0.5
        photoLongTapGesture.delaysTouchesBegan = true
        
        photosCollectionView.addGestureRecognizer(photoLongTapGesture)
       
        if(fetchedResultsController.fetchedObjects!.isEmpty){
            LoadingIndicator.isHidden = false
            var url = FlickrAPI.FlickrEndpoint.coordinates(String(travelLocationCoordinates.latitude), String(travelLocationCoordinates.longitude)).url
            GenericAPIInfo.taskInteractWithAPI(isImageLoading: false,methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: FlickrAPIResponseModel.FlickrAPIResponse.self, completionHandler: handleFlickrAPIPhotosResponse(success:error:))
            
            photosCollectionView.delegate = self
            photosCollectionView.dataSource = self
           setupFetchedResultController()
            photosCollectionView.reloadData()
            
        } else{
            LoadingIndicator.isHidden = true
            noPhotosAlertLabel.isHidden = true
            photosCollectionView.isHidden = false
            
            photosCollectionView.delegate = self
            photosCollectionView.dataSource = self
            photosCollectionView.reloadData()
        }
        
    }
    
    @objc func handlePhotoLongPressDeletion(longPress: UILongPressGestureRecognizer){
        
        if longPress.state != .ended {
              return
          }
        
        let tapPoint = longPress.location(in: photosCollectionView)
        let photoIndex = self.photosCollectionView.indexPathForItem(at: tapPoint)
        
        deleteSpecificPhoto(at: photoIndex!)
        photosCollectionView.reloadItems(at: [photoIndex!])
    }
    
    private func deleteSpecificPhoto(at indexPath: IndexPath){
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        
        dataController.viewContext.delete(photoToDelete)
        do{
            try? dataController.viewContext.save()
//            print("specific photo delete succeeded")
        }
//        catch{
//            print("Failed to delete specific photo due to \(error.localizedDescription)")
//        }
    }
    
    private func insertPhotosToDB(imageData: Data){
        let photoTable = PhotosTable(context: dataController.viewContext)
        photoTable.photo = imageData
        photoTable.longitude = travelLocationCoordinates.longitude as Double
        photoTable.latitude = travelLocationCoordinates.latitude as Double
    }
    
    func handleFlickrAPIPhotosResponse(success: FlickrAPIResponseModel.FlickrAPIResponse?, error: Error?){
        guard let success = success else{
            print("FLICKR API GET response failed : \(error?.localizedDescription)")
            return
        }
       
        var response = FlickrAPIResponseModel.FlickrAPIResponse.init(photos: success.photos, stat: success.stat)
        photosList = response.photos.photo
       
        DispatchQueue.global().async {
            for photo in self.photosList! {
                let url = FlickrAPI.getFlickrImageURL(serverId: photo.server, imageId: photo.id, imageSecret: photo.secret)
            
                    if let data = try? Data(contentsOf: url){
                            self.insertPhotosToDB(imageData: data)
                    }
            }
            
            DispatchQueue.main.async {
                self.LoadingIndicator.isHidden = true
                self.noPhotosAlertLabel.isHidden = true
                self.photosCollectionView.isHidden = false
                
                do{
                    try self.dataController.viewContext.save()
                    print("photos insertion succesful")
                    self.setupFetchedResultController()
                    
                    self.photosCollectionView.reloadData()
                }catch{
                    print("Photo insetion into DB failed due to : \(error.localizedDescription)")
                }
            }
        }
        
      
        
    
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flickr Photo", for: indexPath) as! TravelPhotosCollectionViewCell
      
            DispatchQueue.main.async {
                if let photo = self.fetchedResultsController.fetchedObjects![(indexPath as NSIndexPath).row].photo{
                    cell.photoViewCell.image = UIImage(data: photo)
                }
            }
        return cell
    }
    
    

}
