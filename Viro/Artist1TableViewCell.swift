//
//  Artist1TableViewCell.swift
//  Viro
//
//  Created by Imac RDG on 17/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class Artist1TableViewCell: UITableViewCell {
    @IBOutlet weak var songNumberLbl: UILabel!
    @IBOutlet weak var addBtnOutlet: UIButton!
    @IBOutlet weak var songNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(_ number: Int, songName: String){
        songNumberLbl.text = String(number)
        songNameLbl.text = songName
    }

    @IBAction func addBtnAction(_ sender: AnyObject) {
       // ParseAPIManager().checkAndPost(songNameLbl.text!, albumName: "unknown", image: "")
    }
    
}
