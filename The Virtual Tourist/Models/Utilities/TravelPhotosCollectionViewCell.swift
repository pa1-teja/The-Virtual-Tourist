//
//  TravelPhotosCollectionViewCell.swift
//  The Virtual Tourist
//
//  Created by TEJAKO3-Old Mac on 14/03/23.
//

import UIKit

class TravelPhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoViewCell: UIImageView!
    
    func showLoadingIndicator(){
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator()
    {
        activityIndicator.stopAnimating()
    }
    
    fileprivate var activityIndicator: UIActivityIndicatorView {
      get {
          let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x:self.frame.width/2,
                                       y: self.frame.height/2)
        activityIndicator.stopAnimating()
        self.addSubview(activityIndicator)
        return activityIndicator
      }
    }
}
