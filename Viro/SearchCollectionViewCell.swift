//
//  SearchCollectionViewCell.swift
//  ViroPopularRadioCell
//
//  Created by Gonzalo Duarte  on 10/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    let logPress = UILongPressGestureRecognizer()
    var artist1 : String!
    var imageLink : String!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var radioImagView: UIImageView!
    @IBOutlet weak var longPressUIView: UIView!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(_ name: String, image: String, index: Int, artist: String){
        addButtonOutlet.layer.cornerRadius = self.addButtonOutlet.frame.size.width / 2
        addButtonOutlet.isHidden = true
        
        if index == 0{
            logPress.addTarget(self, action: #selector(PopularRadioCell.longTap( _:)))
            longPressUIView.addGestureRecognizer(logPress)
            artist1 = artist
        }
        nameLbl.text = name
        imageLink = image
        radioImagView.kf.setImage(with: URL(string: image)!, placeholder: UIImage(named: "Logo"))
    }
    
    func longTap(_ sender : UIGestureRecognizer){
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            addButtonOutlet.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 0
                self.radioImagView.alpha = 1
                self.nameLbl.alpha = 1
            })
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "wantedToAdd"), object: nil)
            let data = [nameLbl.text!, artist1, imageLink]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicData"), object: data)
            //ParseAPIManager().checkAndPost(nameLbl.text!, albumName: artist1)
            addButtonOutlet.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 1
                self.radioImagView.alpha = 0.1
                self.nameLbl.alpha = 0.1
            })
        }
    }
    @IBAction func addButtonAction(_ sender: AnyObject) {
        
        //Implement Parse
    }
}
