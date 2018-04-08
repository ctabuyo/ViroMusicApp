//
//  API.swift
//  Viro
//
//  Created by Cristian Tabuyo on 1/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class trendingSingles {
    
    
    func downloadPlaylist() {
        let url = "http://viromusicapp.com/playlist.json"
        Alamofire.request(url, method: .post).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                plName.removeAll()
                plImage.removeAll()
                if let data = response.result.value{
                    let json = JSON(data)
                    
                    for items in json["Playlists"].arrayValue  {
                        plName.append(items["Name"].stringValue)
                        plImage.append(items["Artwork"].stringValue)
                        
                        
                        
                        
                    }
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                break
                
            }

                
        }
    }
    
    func getCharts(_ Country: String, completed: @escaping DownloadComplete)  {
        let url = "https://itunes.apple.com/\(Country)/rss/topsongs/limit=40/json"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            if let data = response.result.value{
                let swiftyJSON = JSON(data)
                
                let movies = swiftyJSON["feed"]["entry"].arrayValue
                
                let titles = movies.map { $0["im:name"]["label"].stringValue }
                let images = movies.map { $0["im:image"][2]["label"].stringValue }
                let artist = movies.map { $0["im:artist"]["label"].stringValue }
                
                print(images)
                
                CHSongs = titles
                CHImages = images
                CHArtist = artist
                
                completed()

            }

            
        }

        
    }
    
    func getSongs(_ Index: Int, completed: @escaping DownloadComplete ) {
        let url = "http://viromusicapp.com/playlist.json"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    
                    plSongName.removeAll()
                    plSongArtist.removeAll()
                    plSongImage.removeAll()
                    plSongLink.removeAll()
                    
                    var items = json["Playlists"].arrayValue
                    
                    for songs in items[Index]["Songs"].dictionaryValue {
                        plSongName.append(songs.0)
                        plSongArtist.append(songs.1[0].stringValue)
                        plSongImage.append(songs.1[1].stringValue)
                        plSongLink.append(songs.1[2].stringValue)
                    }
                    
                    completed()

                }
                
                
                
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
            }
            
        }
 
        
    }
    
        
    

    
    func downloadTrendingSingles(_ completed: @escaping DownloadComplete) {
        let url = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topsongs/limit=15/json"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.result.value{
                    let swiftyJSON = JSON(data)
                    
                    let movies = swiftyJSON["feed"]["entry"].arrayValue
                    
                    let titles = movies.map { $0["im:name"]["label"].stringValue }
                    let images = movies.map { $0["im:image"][2]["label"].stringValue }
                    let artists = movies.map { $0["im:artist"]["label"].stringValue }
                    
                    
                    
                    
                    HomeSongsT = titles
                    HomeSongsAT = artists
                    HomeSongsL = images
                    
                    
                    completed()

                }
                
                
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
            }
            
        }
    }
    
    
    func getAlbumsSongs(_ ID: Int, completed: @escaping DownloadComplete) {
        let urlPath = "https://itunes.apple.com/lookup?id=\(ID)&entity=song"
        let url = URL(string: urlPath)
        APTArtist.removeAll()
        APTNames.removeAll()
        APTImages.removeAll()
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let JSON = response.result.value as! [String: AnyObject]!{
                    if let dict = JSON["results"] as! [[String:Any]]!  {
                        for items in dict {
                            
                            
                            if let AT = items["artistName"] as? String {
                                TDAlbumArtist.append(AT)
                                
                                if let TN = items["trackName"] as? String {
                                    TDAlbumSongs.append(TN)
                                } else {
                                    TDAlbumSongs.append("")
                                }
                                
                                
                            } else {
                                TDAlbumArtist.append("")
                            }
                            
                            if let IM = items["artworkUrl100"] as? String {
                                TDAlbumLinks.append(IM)
                            } else {
                                TDAlbumLinks.append("")
                            }
                            
                        }
                        completed()
                    }
                }
                
                
                break
                
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
                break
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    func getAlbums(_ completed: @escaping DownloadComplete) {
        let url = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topalbums/limit=15/json"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.result.value{
                    let swiftyJSON = JSON(data)
                    
                    let movies = swiftyJSON["feed"]["entry"].arrayValue
                    
                    let titles = movies.map { $0["im:name"]["label"].stringValue }
                    let images = movies.map { $0["im:image"][2]["label"].stringValue }
                    let artists = movies.map { $0["im:artist"]["label"].stringValue }
                    let albumID = movies.map { $0["id"]["attributes"]["im:id"].intValue }
                    
                    print(albumID)
                    
                    for items in images {
                        let newVar = items.replacingOccurrences(of: "170", with: "220")
                        HomeSongsL.append(newVar)
                    }
                    
                    
                    HomeAlbumL = images
                    HomeAlbumN = titles
                    HomeAlbumAT = artists
                    HomeAlbumID = albumID
                    
                    completed()

                }
                
                
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
            }
            
        }
        
    }
    
    
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    
    
}
