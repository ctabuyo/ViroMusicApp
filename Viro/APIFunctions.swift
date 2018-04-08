//
//  GlobalVariablesRadio.swift
//  Viro
//
//  Created by Cristian Tabuyo on 1/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

var Radiocategories = [String]()
var Radioname = [[String]]()
var Radioimage = [[String]]()
var Radiolink = [[String]]()

class RadioAPI {
    
    var radionameProv = [String]()
    var radioimgProv = [String]()
    var radiolinkProv = [String]()
    
    //MARK: - REQUEST
    func downloadRadios(){
        let url = "http://viromusicapp.com/topradios.json"
        Alamofire.request(url, method: .post).validate().responseJSON { response in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    
                    for items in json["Top-Radios"].arrayValue  {
                        Radiocategories.append(items["Name"].stringValue)

                        self.radionameProv.removeAll()
                        self.radioimgProv.removeAll()
                        self.radiolinkProv.removeAll()
                        
                        for radios in items["Radios"].dictionaryValue {
                            print(radios.0)
                            self.radionameProv.append(radios.0)
                            self.radioimgProv.append(radios.1[0].stringValue)
                            self.radiolinkProv.append(radios.1[1].stringValue)
                        }
                        
                        Radioname.append(self.radionameProv)
                        Radioimage.append(self.radioimgProv)
                        Radiolink.append(self.radiolinkProv)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)

                    
                    
                    
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                break
                
            }
            
            
        }
       
        
    }
    
    //MARK: - MY FUNCTIONS
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    
}
