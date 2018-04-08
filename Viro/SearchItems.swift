//
//  SearchItems.swift
//  Viro
//
//  Created by Cristian Tabuyo on 15/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Array where Element: Equatable {
    var orderedSetValue: Array  {
        return reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
}

class iTunes {
    
    
    
    // Function parameters
    fileprivate var _searchParameter : String!
    // Variables
    fileprivate var _songNames = [String]()
    fileprivate var _artistNames = [String]()
    fileprivate var _songTbLinks = [String]()
    fileprivate var _collectionID = [Int]()
    fileprivate var _albumNames = [String]()
    fileprivate var _albumTbLinks = [String]()
    
    var myGroup = DispatchGroup()
    
    var songNames : [String] {
        
        return _songNames
    }
    
    var artistNames : [String]{
        
        return _artistNames
    }
    
    var songTbLinks : [String] {
        
        return _songTbLinks
    }
    
    var collectionID : [Int] {
        
        return _collectionID
    }
    
    var albumNames : [String] {
        
        return _albumNames
    }
    
    var albumTbLinks : [String] {
        
        return _albumNames
    }
    
    var searchParameter : String {
        return _searchParameter
    }
    
    func getAlbums(_ ID: Int, completed: @escaping DownloadComplete) {
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
                                APTArtist.append(AT)
                                
                                if let TN = items["trackName"] as? String {
                                    APTNames.append(TN)
                                } else {
                                    APTNames.append("")
                                }
                                
                                
                            } else {
                                APTArtist.append("")
                            }
                            
                            if let IM = items["artworkUrl100"] as? String {
                                APTImages.append(IM)
                            } else {
                                APTImages.append("")
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
    
    
    
    func getAlbums2(_ ID: Int, completed: @escaping DownloadComplete) {
        let urlPath = "https://itunes.apple.com/lookup?id=\(ID)&entity=album"
        let url = URL(string: urlPath)
        colId.removeAll()
        
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let JSON = response.result.value as! [String: AnyObject]!{
                    if let dict = JSON["results"] as! [[String:Any]]!  {
                        for items in dict {
                            
                            
                            if let WP = items["wrapperType"] as? String , WP == "collection" {
                                if let NM = items["collectionName"] as? String {
                                    ANames.append(NM)
                                } else {
                                    ANames.append("")
                                }
                                
                                if let CI = items["collectionId"] as? Int {
                                   colId.append(CI)
                                } else {
                                    colId.append(0)
                                }
                                
                                if let TN = items["artworkUrl100"] as? String {
                                    let newString = TN.replacingOccurrences(of: "100", with: "600")
                                    AlbumLinks.append(newString)
                                    
                                } else {
                                    AlbumLinks.append("")
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
        let searchFT = search.stringByAddingPercentEncodingForRFC3986()
        let urlPath = "https://itunes.apple.com/search?term=\(searchFT!)&limit=15"
        let url = URL(string: urlPath)
        
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let JSON = response.result.value as! [String: AnyObject]!{
                    if let dict = JSON["results"] as! [[String:Any]]!  {
                        ArtistID.removeAll()
                        AlbumLinks.removeAll()
                        for items in dict {
                            if let SG = items["kind"] as? String , SG == "song" {
                                if let TN = items["trackName"] as? String {
                                    TNames.append(TN)
                                } else {
                                    TNames.append("")
                                }
                                
                                if let AT = items["artistName"] as? String {
                                    ATNames.append(AT)
                                } else {
                                    ATNames.append("")
                                }
                                
                                if let TBN = items["artworkUrl100"] as? String {
                                    let newString = TBN.replacingOccurrences(of: "100", with: "600")
                                    TLinks.append(newString)
                                } else {
                                    TLinks.append("")
                                }
                                
                                if let CN = items["artistId"] as? Int {
                                    ArtistID.append(CN)
 
                                } else {
                                    ArtistID.append(1)
                                }
                                
                                if let TBN2 = items["artworkUrl100"] as? String {
                                    let newString = TBN2.replacingOccurrences(of: "100", with: "600")
                                    ALinks.append(newString)
                                } else {
                                    ALinks.append("")
                                }
                                
                                if let GNR = items["primaryGenreName"] as? String {
                                    GenreSong.append(GNR)
                                } else {
                                    GenreSong.append("")
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
}
