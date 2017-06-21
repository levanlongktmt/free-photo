//
//  PhotoGridViewModel.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit
import CoreLocation

protocol PhotoGridView {
    func photoGridViewDataWasChanged()
}

class PhotoGridViewModel: NSObject {
    var view: PhotoGridView?
    var photos = [PhotoModel]()
    var filter = PhotoFilter()
    func loadPhotos() {
        let locationHelper = (UIApplication.shared.delegate as! AppDelegate).locationHelper
        
        filter.lat = locationHelper.currentLocation!.coordinate.latitude
        filter.lon = locationHelper.currentLocation!.coordinate.longitude
        filter.radius = 5.0
        
        requestLoadPhotos()
    }
    func reloadPhotos() {
        photos.removeAll()
        self.view?.photoGridViewDataWasChanged()
        requestLoadPhotos()
    }
    
    func requestLoadPhotos() {
        BaseConnector.currentConenctor.search(filter: filter) { (result, errCode) in
            if errCode == 0 {
                self.photos = result!.data
                DispatchQueue.main.async {
                    self.view?.photoGridViewDataWasChanged()
                }
            }
        }
    }
}
