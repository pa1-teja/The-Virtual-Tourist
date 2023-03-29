//
//  FlickrPhotosAPI.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 15/03/23.
//

import Foundation


class FlickrAPI{
   
    enum FlickrEndpoint{
        
        static let apiKey = "eee5d2053f94a59e047993649a1ca3b7"
        
        static let apiSecret: String = "907a73c350524117"
        
        static let webAddress: String = "https://api.flickr.com/services/rest"
        
        static let methodName: String = "flickr.photos.search"
        
        static var urlComp = URLComponents(string: webAddress)

        case coordinates(String, String, String)
        
        
        var queryParams: [URLQueryItem]{
            switch self{
                
            case .coordinates(let latitude, let longitude, let pageNumber): return [URLQueryItem(name: "method", value: FlickrAPI.FlickrEndpoint.methodName), URLQueryItem(name: "api_key", value: FlickrAPI.FlickrEndpoint.apiKey), URLQueryItem(name: "format", value: "json"), URLQueryItem(name: "lat", value: latitude), URLQueryItem(name: "lon", value: longitude), URLQueryItem(name: "nojsoncallback", value: "1"), URLQueryItem(name: "per_page", value: "20"),URLQueryItem(name: "page", value: pageNumber)]
            }
        }
            
            var url: URL{
                FlickrEndpoint.urlComp?.queryItems = queryParams
                print("Framed URL : \(FlickrEndpoint.urlComp?.queryItems)")
                return (FlickrEndpoint.urlComp?.url!)!
            }
        }
    
    
        static let imageWebUrl = "https://live.staticflickr.com"
        
    
    class func getFlickrImageURL(serverId:String, imageId: String, imageSecret: String) -> URL{
         let url = imageWebUrl + "/\(serverId)/\(imageId)_\(imageSecret).jpg"
        print("Flickr image URL: \(url)")
        
        return URL(string: url)!
    }
    
    }
