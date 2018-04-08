//
//  HomeCell.swift
//  Viro
//
//  Created by Cristian Tabuyo on 1/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {
    
    @IBOutlet weak var RadioImg: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    var Radio: PopularRadio!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 0
    }
    
    
    func configureCell(_ name1: String, image: String){
        name.text = name1
        RadioImg.kf.setImage(with: URL(string: image)!, placeholder: UIImage(named: "Logo"))
    }
    
}
