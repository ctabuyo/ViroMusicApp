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

class APICalls2 {
    var h = 0
    var successful = true
    
    var videoIDArr = [String]()
    var videoNameArr = [String]()
    
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
                print("Request failed with error: \(response.result.error!)")
                break
            }
        }
        
    }
    
    //plVideoName
    //AlVideoName
    //AlVideoID
    //AlYTSURL
    
    func startPlaying() {
        self.downloadData(AlVideoID){ () -> () in
            if let h = AlYTSURL as String! {
                URL12 = h
                print(AlVideoName)
                Player.sharedInstance.play(h)
            }
        }
    }
    
    
    func checkResult( _ Data: String,  Parameter: String, Artist: String, completed: DownloadComplete) {
        getResults(Parameter, i: 0) { () -> () in
            if self.videoIDArr[0] == "uu30IC_5qJU" {
                self.videoNameArr.remove(at: 0)
                self.videoIDArr.remove(at: 0)
            }
            print(self.videoIDArr)
            print(self.videoNameArr)
            for (index, element) in self.videoNameArr.enumerated() {
                if (element.lowercased().range(of: Parameter.lowercased()) != nil) {
                    AlVideoID = self.videoIDArr[index]
                    AlVideoName = self.videoNameArr[index]
                    self.startPlaying()
                    break
                } else if (element.lowercased().range(of: Data.lowercased()) != nil) || (element.lowercased().range(of: Artist.lowercased()) != nil) {
                    AlVideoID = self.videoIDArr[index]
                    AlVideoName = self.videoNameArr[index]
                    self.startPlaying()
                    break
                } else {
                    let fullNameArr : [String] = Data.components(separatedBy: " ")
                    
                    for words in fullNameArr {
                        print(words)
                        print(element)
                        if element.lowercased().contains(words.lowercased()) {
                            AlVideoID = self.videoIDArr[index]
                            AlVideoName = self.videoNameArr[index]
                            self.startPlaying()
                            break
                        }
                    }
                    break
                }
                
                
            }
        }
    }

    

    
    
    func getResults(_ Text: String, i: Int,  completed: @escaping DownloadComplete) {
        let textf = Text.stringByAddingPercentEncodingForRFC3986()
        print(textf!)
        let url = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=relevance&q=\(textf!)&type=video&maxResults=15&key=AIzaSyDMQBkFHRF1qR6cgWe7HkeOf5NmlRx0CzU"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let dataTop = response.result.value {
                    let swiftyJSON = JSON(dataTop)
                    
                    let stuff = swiftyJSON["items"].arrayValue
                    
                    self.videoIDArr = stuff.map { $0["id"]["videoId"].stringValue }
                    self.videoNameArr = stuff.map { $0["snippet"]["title"].stringValue }
                    
                    
                    
                    
                }
                
                completed()
                
                break
                
                
            case .failure(_):
                print("Request failed with error: \(response.result.error!)")
                break
            }
        }
        
    }
    
    
    
}
