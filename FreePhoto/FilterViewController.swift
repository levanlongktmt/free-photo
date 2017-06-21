//
//  FilterViewController.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FilterViewController: UIViewController {
    var delegate: FilterViewControllerDelegate?
    var btnCancel: UIBarButtonItem!
    var btnDone: UIBarButtonItem!
    var mapView = MKMapView()
    var lbMap = UILabel()
    var mapViewContainer = UIView()
    var pickerContainer = UIView()
    var sliderContainer = UIView()
    var slider = UISlider()
    var lbRadiusTitle = UILabel()
    var lbRadius = UILabel()
    var lbSortType = UILabel()
    var btnChangeSortType = UIButton(type: .system)
    var imgMarker = UIImageView()
    var currentFilter : PhotoFilter!
    var sortType: SortFilter = .radius
    var currentRadius: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(pickerContainer)
        self.view.addSubview(mapViewContainer)
        
        
        mapViewContainer.addSubview(mapView)
        mapViewContainer.addSubview(lbMap)
        lbMap.text = "Move map to select center"
        imgMarker.tintColor = UIColor.red
        imgMarker.image = UIImage(named: "ic_marker")?.withRenderingMode(.alwaysTemplate)
        mapViewContainer.addSubview(imgMarker)
        imgMarker.contentMode = .scaleAspectFit
        
        pickerContainer.addSubview(sliderContainer)
        pickerContainer.addSubview(lbSortType)
        pickerContainer.addSubview(btnChangeSortType)
        sliderContainer.addSubview(lbRadiusTitle)
        sliderContainer.addSubview(slider)
        sliderContainer.addSubview(lbRadius)
        btnChangeSortType.setTitle("Change", for: .normal)
        lbRadiusTitle.text = "Radius"
        lbRadius.text = "\(currentFilter.radius) km"
        slider.value = Float((currentFilter.radius - 1.0) / Double(31))
        slider.addTarget(self, action: #selector(self.sliderChanged), for: .valueChanged)
        self.sortType = currentFilter.sort
        updateSortDisplay()
        
        btnChangeSortType.addTarget(self, action: #selector(self.showSelectSort), for: .touchUpInside)
        setupHeader()
        
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = self.view.frame
        if frame.width > frame.height {
            mapViewContainer.frame = CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height)
            pickerContainer.frame = CGRect(x: frame.width / 2, y: 0, width: frame.width / 2, height: frame.height)
        }
        else {
            mapViewContainer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2)
            pickerContainer.frame = CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height / 2)
        }
        imgMarker.frame = CGRect(x: mapViewContainer.frame.width / 2 - 12,
                                 y: mapViewContainer.frame.height / 2 - 16,
                                 width: 24, height: 24)
        mapView.frame = CGRect(x: 16, y: 32, width: mapViewContainer.frame.width - 32, height: mapViewContainer.frame.height - 32)
        lbMap.frame = CGRect(x: 16, y: 4, width: mapViewContainer.frame.width - 32, height: 24)
        sliderContainer.frame = CGRect(x: 8, y: 8, width: pickerContainer.frame.width - 16, height: 64)
        lbSortType.frame = CGRect(x: 8, y: 72, width: pickerContainer.frame.width - 16, height: 36)
        btnChangeSortType.frame = CGRect(x: pickerContainer.frame.width - 88, y: 72, width: 80, height: 36)
        
        lbRadiusTitle.frame = CGRect(x: 0, y: 0, width: sliderContainer.frame.width, height: 32)
        slider.frame = CGRect(x: 0, y: 32, width: sliderContainer.frame.width - 64, height: 32)
        lbRadius.frame = CGRect(x: sliderContainer.frame.width - 64, y: 32, width: 64, height: 32)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let location = CLLocationCoordinate2D(latitude: currentFilter.lat, longitude: currentFilter.lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    func updateSortDisplay() {
        let shortType = self.sortType == .radius ? "Radius" : "Popular"
        lbSortType.text = "Sort by \(shortType)"
    }
    
    func setupHeader() {
        btnCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressedCancel))
        btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.pressedDone))
        self.navigationItem.title = "Select filter"
        self.navigationItem.leftBarButtonItem = btnCancel
        self.navigationItem.rightBarButtonItem = btnDone
    }
    
    func pressedCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func pressedDone() {
        self.currentFilter.radius = currentRadius
        self.currentFilter.lat = mapView.centerCoordinate.latitude
        self.currentFilter.lon = mapView.centerCoordinate.longitude
        self.currentFilter.sort = sortType
        delegate?.filterViewDidChangeFilter()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showSelectSort() {
        let actionSheet = UIAlertController(title: "Select sort type", message: nil, preferredStyle: .actionSheet)
        let actRadius = UIAlertAction(title: "By Radius", style: .default) { (act) in
            self.sortType = .radius
            self.updateSortDisplay()
        }
        let actPopular = UIAlertAction(title: "By Popular", style: .default) { (act) in
            self.sortType = .rate
            self.updateSortDisplay()
        }
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actRadius)
        actionSheet.addAction(actPopular)
        actionSheet.addAction(actCancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func sliderChanged() {
        currentRadius = round(1.0 + Double(slider.value) * 31.0)
        lbRadius.text = "\(currentRadius) km"
    }
}

protocol FilterViewControllerDelegate {
    func filterViewDidChangeFilter()
}
