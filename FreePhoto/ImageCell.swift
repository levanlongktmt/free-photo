//
//  ImageCell.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCell: UICollectionViewCell {
    var imageView = UIImageView()
    var photo: PhotoModel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }
    
    func setCellPhoto(_ photo: PhotoModel) {
        self.photo = photo
        
        if let url = URL(string: photo.thumbImageUrl) {
            self.imageView.sd_setImage(with: url)
        }
    }
}
