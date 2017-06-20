//
//  BaseConnector.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/20/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

class BaseConnector: NSObject {
    // Just using flickr
    func search(filter: PhotoFilter,  completionHandle: @escaping (PhotoPagingList?, Int) -> Void) {
        guard let request = buildRequest(with: filter) else {
            return
        }
        URLSession.shared.dataTask(with: request) { (data, respose, error) in
            if error != nil {
                completionHandle(nil, -1)
            }
            else {
                if let result = self.decodeResponse(data: data!) {
                    completionHandle(result, 0)
                }
            }
        }.resume()
    }
    
    func buildRequest(with filter: PhotoFilter) -> URLRequest? {
        return nil
    }
    
    func decodeResponse(data: Data) -> PhotoPagingList? {
        return nil
    }
}
