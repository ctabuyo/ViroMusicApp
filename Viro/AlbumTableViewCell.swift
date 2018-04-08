//
//  AlbumTableViewCell.swift
//  Viro
//
//  Created by Imac RDG on 15/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Parse

class AlbumTableViewCell: UITableViewCell {
    
    var artist1 : String!
    var image1: String!
    
    @IBOutlet weak var songNumberLbl: UILabel!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var addBtnOutlet: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - CUSTOM FUNCTIONS
    func configureCell(_ songNumber: Int, songName: String, artistName: String, image: String){
    
        songNumberLbl.text = String(songNumber)
        songNameLbl.text = songName
        artist1 = artistName
        image1 = image
        
    }
    
    //MARK: - IB ACTIONS
    @IBAction func addBtnAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "wantedToAdd"), object: nil)
        let data = [songNameLbl.text, artist1, image1]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "musicData"), object: data)
        
    }
}
