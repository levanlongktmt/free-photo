//
//  ImageScrollView.swift
//  PhotoVault
//
//  Created by Le Van Long on 1/18/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    var zoomView: UIImageView!
    var imageSize: CGSize!
    var pointToCenterAfterResize: CGPoint!
    var scaleToRestotrAfterResize: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    func setupUI() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let boundSizes = self.bounds.size
        if zoomView == nil {
            return
        }
        var frameToCenter = zoomView.frame
        if (frameToCenter.size.width < boundSizes.width) {
            frameToCenter.origin.x = (boundSizes.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        if (frameToCenter.size.height < boundSizes.height) {
            frameToCenter.origin.y = (boundSizes.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        zoomView.frame = frameToCenter
    }
    
    func doubleTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        if self.zoomScale == self.maximumZoomScale {
            self.zoomScale = self.minimumZoomScale
            return
        }
        var newScale = self.zoomScale * 2
        if newScale > maximumZoomScale {
            newScale = maximumZoomScale
        }
        
        let rect = zoomRect(forScale: newScale, with: point)
        self.zoom(to: rect, animated: true)
        
    }
    
    func zoomRect(forScale scale: CGFloat, with centerPoint: CGPoint) -> CGRect {
        var zoomRect = CGRect()
        zoomRect.size.width = imageSize.width / scale
        zoomRect.size.height = imageSize.height / scale
        let newCenter = zoomView.convert(centerPoint, from: self)
        zoomRect.origin.x = newCenter.x - zoomRect.size.width / 2
        zoomRect.origin.y = newCenter.y - zoomRect.size.height / 2
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    func displayImage(image: UIImage) {
        if zoomView == nil {
            //zoomView.removeFromSuperview()
            zoomView = UIImageView(image: image)
            self.addSubview(zoomView)
        }
        self.zoomScale = 1.0
        zoomView.image = image
        self.configureForImageSize(imageSize: image.size)
    }
    
    func configureForImageSize(imageSize: CGSize) {
        self.imageSize = imageSize
        self.contentSize = imageSize
        self.setMaxMinZoomScaleForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
    }
    
    func setFrame(frame: CGRect) {
        let sizeChanging = !__CGSizeEqualToSize(frame.size, self.frame.size)
        if sizeChanging {
            prepareToResize()
        }
        super.frame = frame
        if sizeChanging {
            recoverFromResizing()
        }
    }
    
    func prepareToResize() {
        let boundsCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        pointToCenterAfterResize = self.convert(boundsCenter, to: zoomView)
        scaleToRestotrAfterResize = zoomScale
        
        if scaleToRestotrAfterResize < self.minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestotrAfterResize = 0
        }
    }
    
    func recoverFromResizing() {
        setMaxMinZoomScaleForCurrentBounds()
        let maxZoomScale = max(self.minimumZoomScale, scaleToRestotrAfterResize)
        self.zoomScale = min(self.maximumZoomScale, maxZoomScale)
        let boundsCenter = self.convert(pointToCenterAfterResize, from: zoomView)
        var offset = CGPoint(x: boundsCenter.x - self.bounds.size.width / 2.0,
                             y: boundsCenter.y - self.bounds.size.height / 2.0)
        let maxOffset = self.maximumContentOffset()
        let minOffset = self.minimumContentOffset()
        let realMaxOffsetX = min(maxOffset.x, offset.x)
        let realMaxOffsetY = min(maxOffset.y, offset.y)
        offset.x = max(minOffset.x, realMaxOffsetX)
        offset.y = max(minOffset.y, realMaxOffsetY)
        self.contentOffset = offset
    }
    
    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let imagePortrait = imageSize.height > imageSize.width
        let phonePortrait = boundsSize.height > boundsSize.width
        var minScale = imagePortrait == phonePortrait ? xScale : min(xScale, yScale)
        let maxScale = 2.0 / UIScreen.main.scale
        minScale = minScale > maxScale ? maxScale : minScale
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
    }
    
    func maximumContentOffset() -> CGPoint {
        let contentSize = self.contentSize
        let boundSize = self.bounds.size
        return CGPoint(x: contentSize.width - boundSize.width,
                       y: contentSize.height - boundSize.height)
    }
    func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
}
