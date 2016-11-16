//
//  AlbumViewController.swift
//  SpotifySearch
//
//  Created by Jason Gresh on 10/25/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let validAlbum = album {
            self.title = validAlbum.name
        }
        getImage()
    }
    
    func getImage() {
        guard let validAlbum = album else {
            return
        }
        
        if (validAlbum.images.count > 0) {
            APIRequestManager.manager.getData(endPoint: validAlbum.images[0].url.absoluteString ) { (data: Data?) in
                if  let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        self.imageView.image = validImage
                    }
                }
            }
        }
    }

}
