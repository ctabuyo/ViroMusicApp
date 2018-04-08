//
//  File.swift
//  Viro
//
//  Created by Cristian Tabuyo on 13/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class iTunesAPI {
    
    
    var arrayAlb1 = NSArray()
    var did = false
    
    var array: Int!
    
    var runned = 0
    
    var arrayft1 = [[String]]()
    
    
    func removeDuplicates(_ array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }

    
    
    
        
    
}
