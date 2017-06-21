//
//  PhotoFilter.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/20/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

enum SortFilter {
    case rate
    case updated
    case radius
}

class PhotoFilter: NSObject {
    var lat: Double = 0
    var lon: Double = 0
    var radius: Double = 0
    var pageIndex = 1
    var pageSize = 100
    var sort : SortFilter = .radius
}
