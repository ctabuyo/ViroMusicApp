//
//  PlaylistTableViewCell.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 24/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

   // @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       /* let minValue = CGFloat(0.0)
        let maxValue = CGFloat(0.0)
        
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        xMotion.minimumRelativeValue = minValue
        xMotion.maximumRelativeValue = maxValue
        yMotion.minimumRelativeValue = minValue
        yMotion.maximumRelativeValue = maxValue
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion, yMotion]
        backgroundImage.addMotionEffect(motionEffectGroup)*/
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        //image1.layer.cornerRadius = image1.bounds.height / 2
       // backgroundImage.clipsToBounds = true
    }
    
    func configureCell(_ name: String, number: Int){
        subtitleLbl.text = String("\(number) songs")
        titleLbl.text = name
        //backgroundImage.image = image
    }

}
