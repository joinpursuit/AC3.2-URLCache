//
//  APIRequestManager.swift
//  SpotifySearch
//
//  Created by Jason Gresh on 10/31/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class APIRequestManager {
    
    static let manager = APIRequestManager()
    private init() {}
    
    func getData(endPoint: String, callback: @escaping (Data?) -> Void) {
        guard let myURL = URL(string: endPoint) else { return }
        
        getData(endPoint: myURL, callback: callback)
    }
    
    func getData(endPoint: URL, callback: @escaping (Data?) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var request = URLRequest(url: endPoint)
        request.cachePolicy = .useProtocolCachePolicy // fiddle with this to change behavior
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request)?.response as? HTTPURLResponse {
            print("URL \(endPoint) FOUND IN CACHE")
            if let cacheControl = cachedResponse.allHeaderFields["Cache-Control"] as? String {
                print("Cache-Control: \(cacheControl)")
            }
            
            if let lastModified = cachedResponse.allHeaderFields["Last-Modified"] as? String {
                print("Last-Modified: \(lastModified)")
                
                //let bogusTimestamp = "Fri, 1 Jan 2016 09:58:28 GMT"
                request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
            }
        }
        
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error durring session: \(String(describing: error))")
            }
            guard let validData = data else { return }
            
            callback(validData)
        }.resume()
    }
}
