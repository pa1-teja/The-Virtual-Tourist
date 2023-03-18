//
//  FlickrAPIResponseModel.swift
//  The Virtual Tourist
//
//  Created by Venkata Sai Pavan Teja Kona on 17/03/23.
//

import Foundation


class FlickrAPIResponseModel{
    
    struct FlickrAPIResponse: Codable{
        
        var photos : Photos
        var stat   : String
        
        enum CodingKeys: String, CodingKey {
            case photos = "photos"
            case stat   = "stat"
        }
    }
    
    struct Photos: Codable{
        var page    : Int
        var pages   : Int
        var perpage : Int
        var total   : Int
        var photo   : [Photo]
        
        enum CodingKeys: String, CodingKey {
            
            case page    = "page"
            case pages   = "pages"
            case perpage = "perpage"
            case total   = "total"
            case photo   = "photo"
        }
    }
        
        struct Photo: Codable{
            var id       : String
            var owner    : String
            var secret   : String
            var server   : String
            var farm     : Int
            var title    : String
            var ispublic : Int
            var isfriend : Int
            var isfamily : Int
            
            enum CodingKeys: String, CodingKey {
                
                case id       = "id"
                case owner    = "owner"
                case secret   = "secret"
                case server   = "server"
                case farm     = "farm"
                case title    = "title"
                case ispublic = "ispublic"
                case isfriend = "isfriend"
                case isfamily = "isfamily"
                
            }
        }
    }
