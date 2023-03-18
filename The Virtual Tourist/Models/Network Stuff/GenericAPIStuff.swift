//
//  GenericAPIStuff.swift
//  The Virtual Tourist
//
//  Created by Venkata Sai Pavan Teja Kona on 17/03/23.
//

import Foundation
import UIKit

class GenericAPIInfo{
    
    enum MethodType: String{
        case GET
        
        var stringValue:String{
            switch self{
            case .GET : return "GET"
            }
        }
    }
    
    
    class func taskInteractWithAPI<ResponseType: Decodable>(isImageLoading: Bool,methodType: GenericAPIInfo.MethodType, url: URL, responseType: ResponseType.Type, completionHandler: @escaping(ResponseType?, Error?) -> Void){
        
        switch methodType{
        case .GET:
            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                guard let data = data else{
                    print("GET request failed in function : GenericAPIInfo.taskInteractWithAPI")
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                    return
                }
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                   print("JSON Data : \(JSONString)")
                }
                let decoder = JSONDecoder()
                do{
                    if(!isImageLoading){
                        let jsonResponseObject = try decoder.decode(ResponseType.self, from: data)
                        
                        DispatchQueue.main.async {
                            completionHandler(jsonResponseObject, nil)
                        }
                    } else {
                        let fethcedImage = UIImage(data: data)
                        
                        DispatchQueue.main.async {
                            completionHandler((fethcedImage as! ResponseType),nil)
                        }
                        
                    }
                } catch{
                    print("JSON error: \(error.localizedDescription)")
                }
            })
            task.resume()
            return
        }
    }
}
