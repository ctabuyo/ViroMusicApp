//
//  APICalls.swift
//  Viro
//
//  Created by Cristian Tabuyo on 27/09/2016.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APICalls {
    var h = 0
    var successful = true
    var songName = ""
    var howmany = -1
    var finished = false
    var failed = false
    
    func downloadData(_ URL: String, completed: @escaping DownloadComplete)  {
        let url = "http://www.yt-mp3.com/fetch?v=\(URL)&apikey=1234567"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    if let arr = json.dictionaryObject! as [String : AnyObject]! {
                        if let stat = arr["status"] as? String {
                            if stat == "timeout"  {
                                print("Error ocurred")
                                self.downloadDataF(URL) { () -> () in
                                    completed()
                                }
                                if (arr["ready"] as! Bool!) != nil {
                                    print("Error ocurred")
                                    self.downloadDataF(URL) { () -> () in
                                        completed()
                                    }
                                }
                            } else {
                                if let url = arr["url"]! as? String {
                                    let urlp = url
                                    let urld = urlp.replacingOccurrences(of: "//", with: "http://")
                                    YTSURL = urld
                                    completed()
                                }
                            }
                        }
                        
                    }
                    
                    break
                    
                }
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
                break
            }
        }
        
    }
    func downloadDataF(_ URL: String, completed: @escaping DownloadComplete)  {
        let url = "http://www.youtubeinmp3.com/fetch/?format=JSON&video=https://www.youtube.com/watch?v=\(URL)"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    if let arr = json.dictionaryObject! as [String : AnyObject]! {
                        if let urlString = arr["link"] as? String {
                            YTSURL = urlString
                            completed()
                        }
                    }
                    
                    
                    break
                    
                }
            case .failure(_):
                if pltype == PlayerType.artist {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "playNN"), object: nil)
                }
                print("Request failed with error: \(response.result.error!)")
                break
            }
        }
        
    }

    
    func checkResult( _ Data: String,  Parameter: String, Artist: String, completed: DownloadComplete) {
        songName = Data
        var matched = false
        let resultArr = Data.components(separatedBy: " ")
        let artistArr = Artist.components(separatedBy: " ")
        for var words in resultArr {
            if words.characters.count == 1 {
                words = "\(words)hg"
            }
            if howmany == -1 || howmany == 0 {
                for words2 in artistArr {
                    print(videoName)
                    if plVideoName.lowercased().range(of: words.lowercased()) != nil && plVideoName.lowercased().range(of: words2.lowercased()) != nil {
                        matched = true
                    }
                }
            } else {
                if plVideoName.lowercased().range(of: words.lowercased()) != nil {
                    matched = true
                }
                
            }
            
            
        }
        if matched == true {
            completed()
            print("This is the URL\(plVideoID)")
            downloadData(plVideoID){ () -> () in
                if let h = YTSURL as String! {
                    URL12 = h
                    Player.sharedInstance.play(h)
                }
            }
            
        } else {
            howmany = howmany + 1
            h += 1
            if failed == false {
                getResults(Parameter, i: h) { () -> () in
                    self.checkResult(Data, Parameter: Parameter, Artist: Artist) { () -> () in
                    }
                }
            } else {
                getResults(Data, i: h) { () -> () in
                    print(Data)
                    self.checkResult(Data, Parameter: Parameter, Artist: Artist) { () -> () in
                    }
                }
            }
            
        }
        
    }
    
    
    func getResults(_ Text: String, i: Int,  completed: @escaping DownloadComplete) {
        let textf = Text.stringByAddingPercentEncodingForRFC3986()
        print(textf!)
        let url = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(textf!)&type=video&maxResults=50&key=AIzaSyDMQBkFHRF1qR6cgWe7HkeOf5NmlRx0CzU"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let JSON = response.result.value as! [String: AnyObject]!{
                    if let dict = JSON["items"] as! [[String:Any]]!  {
                        if dict.isEmpty == false{
                            if let id = dict[i]["id"] as! [String: AnyObject]! {
                                if let videoid = id["videoId"] as! String! {
                                    plVideoID = videoid as String
                                }
                            }
                            if let snipped = dict[i]["snippet"] as! [String: AnyObject]! {
                                if let videoid = snipped["title"] as! String! {
                                    plVideoName = videoid as String
                                }
                            }
                            
                            
                        } else {
                            self.failed = true
                            
                        }
                        
                        
                        
                    }
                    
                    completed()
                    
                    break
                    
                }
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
                break
            }
        }
        
    }

    
    
}
