//
//  AlbumsTableViewController.swift
//  SpotifySearch
//
//  Created by Jason Gresh on 10/25/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

fileprivate let apiURLRoot = "http://ws.audioscrobbler.com/2.0/"
fileprivate let apiKey = "1ce6fda8a223aa4b7fa0cafe4dc3d3d0"
fileprivate let apiKeyQueryKey = "api_key"

class AlbumsTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    var albums: [Album] = []
    let searchTerm = "kanye west"
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        printCacheStats()
        
        self.title = searchTerm
        
        if let escapedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = getAlbumsByArtist(escapedString){
           
            APIRequestManager.manager.getData(endPoint: url) { (data: Data?) in
                if  let validData = data,
                    let validAlbums = Album.albums(from: validData) {
                    self.albums = validAlbums
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func getAlbumsByArtist(_ artistName: String) -> URL? {
        let getAlbumsByArtistURL = "\(apiURLRoot)?method=artist.gettopalbums"
        
        guard var urlComponents = URLComponents(string: getAlbumsByArtistURL) else { return nil }
        
        let methodQuery = URLQueryItem(name: "method", value: "artist.gettopalbums")
        let apiKeyQuery = URLQueryItem(name: apiKeyQueryKey, value: apiKey)
        let artistQuery = URLQueryItem(name: "artist", value: artistName)
        let formatQuery = URLQueryItem(name: "format", value: "json")
        
        urlComponents.queryItems = [methodQuery, apiKeyQuery, artistQuery, formatQuery]
        
        guard let url = urlComponents.url else { return nil }
        return url
    }
    
    func printCacheStats() {
        print("Cache on disk: \(URLCache.shared.currentDiskUsage) of \(URLCache.shared.diskCapacity)")
        print("Cache in memory: \(URLCache.shared.currentMemoryUsage) of \(URLCache.shared.memoryCapacity)")
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
