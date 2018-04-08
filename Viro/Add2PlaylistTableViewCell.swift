//
//  Add2PlaylistTableViewCell.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 25/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class Add2PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ name: String){
        titleLbl.text = name
    }

}
