//
//  AlbumsTableViewController.swift
//  SpotifySearch
//
//  Created by Jason Gresh on 10/25/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {
    var albums: [Album] = []
    let searchTerm = "kanye west"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = searchTerm
        let escapedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        APIRequestManager.manager.getData(endPoint: "https://api.spotify.com/v1/search?q=\(escapedString!)&type=album&limit=50") { (data: Data?) in
            if  let validData = data,
                let validAlbums = Album.albums(from: validData) {
                self.albums = validAlbums
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)
        
        // get a reference to the album in question
        let album = albums[indexPath.row]
        
        // set the name
        cell.textLabel?.text = album.name
        
        // reset the image to nil
        cell.imageView?.image = nil
        
        // make the call to get the correct image
        if (album.images.count > 2) {
            APIRequestManager.manager.getData(endPoint: album.images[2].url.absoluteString ) { (data: Data?) in
                if  let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = validImage
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let avc = segue.destination as? AlbumViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            avc.album = albums[indexPath.row]
        }
    }
}
