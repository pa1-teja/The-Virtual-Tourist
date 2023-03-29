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
    
    var location:LocationPinTable!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var noPhotosAlertLabel: UILabel!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var newFlickrCollectionPhotos: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var photosList:[FlickrAPIResponseModel.Photo]?
    
    var offlinePhotos: [PhotosTable] = []
    
    @IBAction func discardAndGetFreshPhotos(_ sender: Any) {
        batchDeletePhotosOfSpecificLocation()
        fetchFlickrImages(pageNumber: Int.random(in: 2..<10))
    }
    
    fileprivate func setupFetchedResultController(){
        let fetchRequest: NSFetchRequest<PhotosTable> = PhotosTable.fetchRequest()
        
        let predicate = NSPredicate(format: "location == %@", location)
        
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        
        
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "PhotosCache")
        
//        fetchedResultsController.delegate = self
        
        do{
            
            offlinePhotos = try dataController.viewContext.fetch(fetchRequest)
//            try fetchedResultsController.performFetch()
        
            print("location coord passed in : \(location.longitude) / \(location.latitude)")
            
            for photo in offlinePhotos{
                print("location coord from photo DB : \(photo.location?.latitude) / \(photo.location?.longitude)")
            }
            
            
            print("database images count : \(String(describing: offlinePhotos.count))")
        }catch{
            fatalError("Fetch action could not be performed : \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
            Utils.markLocation(locationCoordinates: travelLocationCoordinates, mapView: mapView)
        setupFetchedResultController()
        
        let photoLongTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoLongPressDeletion(longPress:)))
        photoLongTapGesture.minimumPressDuration = 0.5
        photoLongTapGesture.delaysTouchesBegan = true
        
        photosCollectionView.addGestureRecognizer(photoLongTapGesture)
       
        if(offlinePhotos.isEmpty){
            
            fetchFlickrImages(pageNumber: 1)
            
        } else{
            photosCollectionView.isHidden = false
            loadingIndicator.isHidden = true
            noPhotosAlertLabel.isHidden = true
            newFlickrCollectionPhotos.isEnabled = true
            photosCollectionView.delegate = self
            photosCollectionView.dataSource = self
            photosCollectionView.reloadData()
        }
        
    }
    
    func fetchFlickrImages(pageNumber: Int){
        newFlickrCollectionPhotos.isEnabled = false
        noPhotosAlertLabel.isHidden = false
        loadingIndicator.isHidden = false
        newFlickrCollectionPhotos.isEnabled = false
        let url = FlickrAPI.FlickrEndpoint.coordinates(String(travelLocationCoordinates.latitude), String(travelLocationCoordinates.longitude),String(pageNumber)).url
        GenericAPIInfo.taskInteractWithAPI(isImageLoading: false,methodType: GenericAPIInfo.MethodType.GET, url: url, responseType: FlickrAPIResponseModel.FlickrAPIResponse.self, completionHandler: handleFlickrAPIPhotosResponse(success:error:))
    }
    
    @objc func handlePhotoLongPressDeletion(longPress: UILongPressGestureRecognizer){
        
        if longPress.state != .ended {
              return
          }
        
        let tapPoint = longPress.location(in: photosCollectionView)
        let photoIndex = self.photosCollectionView.indexPathForItem(at: tapPoint)
        
        deleteSpecificPhoto(at: photoIndex!)
        setupFetchedResultController()
        photosCollectionView.reloadItems(at: [photoIndex!])
    }
    
    private func deleteSpecificPhoto(at indexPath: IndexPath){
        let rowVal = (indexPath as NSIndexPath).row
        let photoToDelete = offlinePhotos[(indexPath as NSIndexPath).row]
        
        do{
            dataController.viewContext.delete(photoToDelete)
            try dataController.viewContext.save()
            print("specific photo delete succeeded")
        }catch{
            print("Failed to delete specific photo due to \(error.localizedDescription)")
        }
    }
    
    private func batchDeletePhotosOfSpecificLocation(){
        DispatchQueue.global().async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotosTable")
            
            
            let predicate = NSPredicate(format: "location == %@", self.location)
            
            let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
            
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do{
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try self.dataController.viewContext.execute(deleteRequest)
                try  self.dataController.viewContext.save()
            }catch{
                print("Failed to delete all the photos dure to : \(error.localizedDescription)")
            }
        }
        
    }
    
    private func insertPhotosToDB(imageData: Data){
        let photoTable = PhotosTable(context: dataController.viewContext)
        photoTable.photo = imageData
        photoTable.location = location
    }
    
    func handleFlickrAPIPhotosResponse(success: FlickrAPIResponseModel.FlickrAPIResponse?, error: Error?){
        guard let success = success else{
            print("FLICKR API GET response failed : \(String(describing: error?.localizedDescription))")
            return
        }
        
        let response = FlickrAPIResponseModel.FlickrAPIResponse.init(photos: success.photos, stat: success.stat)
        photosList = response.photos.photo
        
        noPhotosAlertLabel.isHidden = true
        loadingIndicator.isHidden = true
        newFlickrCollectionPhotos.isEnabled = true
        
        photosCollectionView.isHidden = false
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.reloadData()
        }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( offlinePhotos.count > 0){
            return offlinePhotos.count
        }else{
            return photosList!.count
       }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flickr Photo", for: indexPath) as! TravelPhotosCollectionViewCell
        
        cell.imageLoadingIndicator.isHidden = false
        
        if(offlinePhotos.isEmpty){
            let photo = self.photosList![(indexPath as NSIndexPath).row]
            let url = FlickrAPI.getFlickrImageURL(serverId: photo.server, imageId: photo.id, imageSecret: photo.secret)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url){
                        DispatchQueue.main.async {
                            cell.imageLoadingIndicator.isHidden = true
                            cell.photoViewCell.image = UIImage(data: data)
                        }
                        self.insertPhotosToDB(imageData: data)
                    }
                }
           
            
        }else{
            cell.imageLoadingIndicator.isHidden = false
            DispatchQueue.main.async {
                if let photo = self.offlinePhotos[(indexPath as NSIndexPath).row].photo{
                    cell.imageLoadingIndicator.isHidden = true
                    cell.photoViewCell.image = UIImage(data: photo)
                }
            }
        }
        return cell
    }
    
    

}
