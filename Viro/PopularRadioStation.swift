//
//  PopularRadioStation.swift
//  Viro
//
//  Created by Cristian Tabuyo on 9/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation


class PopularRadio {
    fileprivate var _name: String!
    fileprivate var _image: String!
    
    
    
    var name: String {
       return _name
    }
    
    var image: String {
        return _image
    }
    
    
    
    init(name: String, image: String){
        self._name = name
        self._image = image
        
    }
}
