//
//  FlickrConnector.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/20/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

class FlickrConnector: BaseConnector {
    private let API_KEY = "2483f25d8d0c1f928054f14921bf37e4"
    private let API_FORMAT = "https://api.flickr.com/services/rest/?method=%@&%@"
    private let SEARCH_METHOD = "flickr.photos.search"
    private let GET_PLACE_INFO = "flickr.places.getInfo"
    private let MAX_RADIUS_ALLOW: Double = 32.0
    private let PHOTO_URL_TEMP = "https://farm%d.staticflickr.com/%d/%@_%@_%@.jpg"
    private let THUMB = "q"
    private let HUGE = "b"
    override func buildRequest(with filter: PhotoFilter) -> URLRequest? {
        var params = [String: Any]()
        params["api_key"] = API_KEY
        params["lat"] = filter.lat
        params["lon"] = filter.lon
        params["radius"] = filter.radius < 1 ? 1 : filter.radius > MAX_RADIUS_ALLOW ? MAX_RADIUS_ALLOW : filter.radius
        params["radius_units"] = "km"
        params["page"] = filter.pageIndex
        params["per_page"] = filter.pageSize
        params["media"] = "photos"
        if filter.sort == .rate {
            params["sort"] = "interestingness-desc"
        }
        params["extras"] = "geo"
        let query = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let urlStr = String(format: API_FORMAT, SEARCH_METHOD, query)
        if let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            return request
        }
        return nil
    }
    
    override func decodeResponse(data: Data) -> PhotoPagingList? {
        let xml = SWXMLHash.parse(data)
        let status: String = try! xml["rsp"].value(ofAttribute: "stat")
        if status != "ok" { return nil }
        let result = PhotoPagingList()
        
        result.pageCount = (try? xml["rsp"]["photos"].value(ofAttribute: "pages")) ?? 1
        result.pageIndex = (try? xml["rsp"]["photos"].value(ofAttribute: "page")) ?? 1
        for item in xml["rsp"]["photos"].children {
            let photo = PhotoModel()
            photo.lat = try! item.value(ofAttribute: "latitude")
            photo.lon = try! item.value(ofAttribute: "longitude")
            photo.placeId = (try? item.value(ofAttribute: "place_id")) ?? ""
            let farmId : Int = try! item.value(ofAttribute: "farm")
            let serverId: Int = try! item.value(ofAttribute: "server")
            let id: String = try! item.value(ofAttribute: "id")
            let secret: String = try! item.value(ofAttribute: "secret")
            photo.thumbImageUrl = String(format: PHOTO_URL_TEMP, farmId, serverId, id, secret, THUMB)
            photo.imageUrl = String(format: PHOTO_URL_TEMP, farmId, serverId, id, secret, HUGE)
            result.data.append(photo)
        }
        
        return result
    }
    
    func getLocationInfo(id: String, handle: @escaping (String) -> Void) {
        var params = [String: Any]()
        params["api_key"] = API_KEY
        params["place_id"] = id
        let query = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let urlStr = String(format: API_FORMAT, GET_PLACE_INFO, query)
        if let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, responseq, err) in
                if err == nil {
                    self.handleLocationResponse(data: data!, viewHandler: handle)
                }
            }).resume()
        }
    }
    
    func handleLocationResponse(data: Data, viewHandler: @escaping (String) -> Void) {
        let xml = SWXMLHash.parse(data)
        let status: String = try! xml["rsp"].value(ofAttribute: "stat")
        if status != "ok" { return }
        let detailPlace = xml["rsp"]["place"]["county"].element?.text
        viewHandler(detailPlace ?? "")
    }
}
