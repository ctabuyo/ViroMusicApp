//
//  BrowseCell.swift
//  Viro
//
//  Created by Cristian Tabuyo on 12/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class BrowseCell: UITableViewCell {

    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var mainTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ image1: UIImage, text: String) {
        mainImg.image = image1
        mainTxt.text = text
        
    }

}
