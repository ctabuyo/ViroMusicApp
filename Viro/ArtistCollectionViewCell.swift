//
//  ArtistCollectionViewCell.swift
//  Viro
//
//  Created by Imac RDG on 17/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class ArtistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumNameLbl: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0
        
    }
    
    
    func configureCell(_ album: String, Img: String){
        albumNameLbl.text = album
        albumImageView.kf.setImage(with: URL(string:Img)!, placeholder: UIImage(named: "Logo"))
    }
}
