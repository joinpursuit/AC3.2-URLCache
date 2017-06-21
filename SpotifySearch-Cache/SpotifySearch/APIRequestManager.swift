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
        
        session.dataTask(with: endPoint) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error durring session: \(String(describing: error))")
            }
            guard let validData = data else { return }
            
            callback(validData)
        }.resume()
    }
}
