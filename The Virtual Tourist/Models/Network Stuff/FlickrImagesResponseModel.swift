//
//  FlickrImagesResponseModel.swift
//  The Virtual Tourist
//
//  Created by Venkata Sai Pavan Teja Kona on 18/03/23.
//

import Foundation
import UIKit

class FlickrImageResponseModel{
    
    struct FlickrImage: Codable{
        let fetchedImage: UIImage
        
        init(fetchedImage: UIImage) {
            self.fetchedImage = fetchedImage
        }
    }
    
}
