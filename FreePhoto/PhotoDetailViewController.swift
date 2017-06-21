//
//  PhotoDetailViewController.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage

class PhotoDetailViewController: UIViewController {
    
    var imageView = ImageScrollView()
    var dimBackgroundView = UIView()
    var mapView = MKMapView()
    var photo: PhotoModel!
    var isShowingMap = false
    var locationTitle = ""
    var apiConnector = FlickrConnector()
    var progressBar : UIProgressView!
    
    var btnViewMap: UIBarButtonItem!
    var btnHideMap: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar = UIProgressView(progressViewStyle: .default)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(imageView)
        self.view.addSubview(progressBar)
        self.view.addSubview(dimBackgroundView)
        self.view.addSubview(mapView)
        progressBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 3.0)
        mapView.isHidden = true
        dimBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimBackgroundView.isHidden = true
        if photo.placeId != "" {
            BaseConnector.currentConenctor.getLocationInfo(id: photo.placeId) { (result) in
                self.locationTitle = result
            }
        }
        
        if let url = URL(string: photo.imageUrl) {
            self.view.sd_internalSetImage(with: url, placeholderImage: nil, options: .init(rawValue: 0), operationKey: nil, setImageBlock: { (image, _) in
                if image != nil {self.imageView.displayImage(image: image!)}
            }, progress: { (val1, val2, _) in
                DispatchQueue.main.async {
                    self.progressBar.setProgress(Float(val1) / Float(val2), animated: true)
                }
            }, completed: { (_, _, _, _) in
                DispatchQueue.main.async {
                    self.progressBar.isHidden = true
                }
            })
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleMapView))
        dimBackgroundView.addGestureRecognizer(tap)
        
        setupNav()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(origin: .zero, size: self.view.frame.size)
        dimBackgroundView.frame = imageView.frame
        
        let frameSize = imageView.frame.size
        if isShowingMap {
            mapView.frame = CGRect(x: 0, y: frameSize.height * 0.4, width: frameSize.width, height: frameSize.height * 0.7)
        }
        else {
            mapView.frame = CGRect(x: 0, y: frameSize.height , width: frameSize.width, height: frameSize.height * 0.7)
        }
    }
    
    
    func setupNav() {
        self.btnViewMap = UIBarButtonItem(title: "View Map", style: .plain, target: self, action: #selector(self.toggleMapView))
        self.btnHideMap = UIBarButtonItem(title: "Hide Map", style: .plain, target: self, action: #selector(self.toggleMapView))
        self.navigationItem.rightBarButtonItem = btnViewMap
    }
    
    func markPinToMapview() {
        let location = CLLocationCoordinate2D(latitude: photo.lat, longitude: photo.lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = locationTitle
        mapView.addAnnotation(anotation)
    }
    
    func toggleMapView() {
        let frameSize = imageView.frame.size
        self.btnViewMap.isEnabled = false
        self.btnHideMap.isEnabled = false
        if isShowingMap {
            UIView.animate(withDuration: 0.3, animations: { 
                self.mapView.frame = CGRect(x: 0, y: frameSize.height , width: frameSize.width, height: frameSize.height * 0.7)
                self.dimBackgroundView.alpha = 0
            }, completion: { (animated) in
                self.dimBackgroundView.isHidden = true
                self.mapView.isHidden = true
                self.isShowingMap = false
                self.btnViewMap.isEnabled = true
                self.btnHideMap.isEnabled = true
                self.navigationItem.rightBarButtonItem = self.btnViewMap
            })
        }
        else {
            self.mapView.isHidden = false
            self.dimBackgroundView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.mapView.frame = CGRect(x: 0, y: frameSize.height * 0.3, width: frameSize.width, height: frameSize.height * 0.7)
                self.dimBackgroundView.alpha = 1
            }, completion: { (animated) in
                self.isShowingMap = true
                self.btnViewMap.isEnabled = true
                self.btnHideMap.isEnabled = true
                self.navigationItem.rightBarButtonItem = self.btnHideMap
                if self.mapView.annotations.count == 0 {
                    self.markPinToMapview()
                }
            })
        }
    }
}
