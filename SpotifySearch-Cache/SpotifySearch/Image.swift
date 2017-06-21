//
//  Image.swift
//  SpotifySearch
//
//  Created by Jason Gresh on 10/31/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class Image {
    let url: URL
    let size: String
    
    init?(from dictionary: [String:AnyObject]) {
        if let size = dictionary["size"] as? String,
            let url = dictionary["#text"] as? String,
            let validURL = URL(string: url) {
            self.size = size
            self.url = validURL
        }
        else {
            return nil
        }
    }
}
