//
//  Artist.swift
//  Viro
//
//  Created by Cristian Tabuyo on 30/09/2016.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class artistData {
    
    
    func getAlbums(_ ID: Int, completed: @escaping DownloadComplete) {
        let urlPath = "https://itunes.apple.com/lookup?id=\(ID)&entity=album"
        let url = URL(string: urlPath)
        colId.removeAll()
        AlbumsArtist.removeAll()
        AlbumsArtist = [String]()
        ImagesArtist.removeAll()
        ImagesArtist = [String]()
        
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let JSON = response.result.value as! [String: AnyObject]!{
                    if let dict = JSON["results"] as! [[String:Any]]!  {
                        for items in dict {
                            
                            
                            if let WP = items["wrapperType"] as? String , WP == "collection" {
                                if let NM = items["collectionName"] as? String {
                                    AlbumsArtist.append(NM)
                                } else {
                                    AlbumsArtist.append("")
                                }
                                
                                if let CI = items["collectionId"] as? Int {
                                    AlbumColId.append(CI)
                                } else {
                                    AlbumColId.append(0)
                                }
                                
                                if let TN = items["artworkUrl100"] as? String {
                                    let newString = TN.replacingOccurrences(of: "100", with: "600")
                                    ImagesArtist.append(newString)
                                    
                                } else {
                                    ImagesArtist.append("")
                                }
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
    
    
    
    
    func getTracks(_ search: String, completed: @escaping DownloadComplete) {
        let trimmed = search.trimmingCharacters(in: CharacterSet.whitespaces)
        let searchFT = trimmed.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal, range: nil)
        let urlPath = "https://itunes.apple.com/search?term=\(searchFT)"
        let url = URL(string: urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        Alamofire.request(url!, method: .get).responseJSON { response in
            let result = response.result.value as! [String: AnyObject]!
            if let dict = result?["results"] as! [[String:Any]]! {
                TracksArtist = [String]()
                for items in dict {
                    
                    if let albums = items["discNumber"] as? Int {
                        if albums == 1 {
                            if let n = items["trackNumber"] as? Int {
                                if n == 1 || n == 2 || n == 3 || n == 4 || n == 5 {
                                    if let TN = items["trackName"] as? String {
                                        TracksArtist.append(TN)
                                    } else {
                                        TracksArtist.append("")
                                    }

                                }
                            }
                        }
                            
                    }
                }
                completed()   
                
            }
            
        }
        
        
    }
    
}
