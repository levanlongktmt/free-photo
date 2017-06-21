//
//  PhotoGridViewController.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

class PhotoGridViewController: UIViewController {

    var collectionView: UICollectionView!
    
    var viewmodel = PhotoGridViewModel()
    var btnFilter : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = calculateItemSize(from: self.view.frame.size)
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        viewmodel.view = self
        
        let locationHelper = (UIApplication.shared.delegate as! AppDelegate).locationHelper
        locationHelper.locationUpdated = viewmodel.loadPhotos
        locationHelper.requestCurrentLocation()
        btnFilter = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(self.pressedFilter))
        self.navigationItem.leftBarButtonItem = btnFilter
        self.navigationItem.title = "List Photos"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.itemSize =  calculateItemSize(from: size)
        flowLayout.invalidateLayout()
    }
    
    func calculateItemSize(from size: CGSize) -> CGSize {
        var itemWidth: CGFloat = 80
        if size.width > size.height {
            itemWidth = (size.width - 6) / 7
        }
        else {
            itemWidth = (size.width - 3) / 4
        }
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func pressedFilter() {
        let filterVc = FilterViewController()
        filterVc.delegate = self
        filterVc.currentFilter = viewmodel.filter
        let nav = UINavigationController(rootViewController: filterVc)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.isOpaque = false
        self.present(nav, animated: true, completion: nil)
    }
    
}

extension PhotoGridViewController: PhotoGridView {
    func photoGridViewDataWasChanged() {
        collectionView.reloadData()
    }
}

extension PhotoGridViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        cell.setCellPhoto(viewmodel.photos[indexPath.item])
        return cell
    }
}

extension PhotoGridViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoDetailViewController()
        vc.photo = viewmodel.photos[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PhotoGridViewController : FilterViewControllerDelegate {
    func filterViewDidChangeFilter() {
        viewmodel.reloadPhotos()
    }
}
