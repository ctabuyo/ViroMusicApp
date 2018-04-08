//
//  SearchAPIFunctions.swift
//  Viro
//
//  Created by Cristian Tabuyo on 1/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//STRING EXTENSION
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

class searchAPI {
    
    
    //MARK: - QUERY
    func filterContentForSearchText() {
        
        let url = "http://api.dirble.com/v2/search/\(Parameter.removeWhitespace())?token=39fdc608e2c6d96b6261c9557e"
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                radioNames.removeAll()
                linksSC.removeAll()
                names.removeAll()
                if let arr = json.arrayObject as? [[String:AnyObject]] {
                    var myRadio = [String]()
                    var link = [String]()
                    for items in arr{
                        let name = items["name"] as? String
                        let stream = items["streams"]
                        if let n = stream{
                            if let c = n[0]["stream"] as? String, let cr = n[0]["status"] as? Int {
                                if cr == 1 { // If status is equal to 1, show the radio because the radio streaming is online.
                                    let h = SearchRadio(name: name!)
                                    radioNames.append(h)
                                    link.append(c)
                                    myRadio.append(name!)
                                    NSNotificationCenter.defaultCenter().postNotificationName("loadSC", object: nil)
                                }
                                
                            }
                        }
                        
                        
                    }
                    linksSC.append(link)
                    names.append(myRadio)
                    link.removeAll()
                    myRadio.removeAll()
                    
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("loadSC", object: nil)
        
    }
    
}