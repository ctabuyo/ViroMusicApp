  //
//  PopularRadioCell.swift
//  Viro
//
//  Created by Cristian Tabuyo on 9/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit


class PopularRadioCell: UICollectionViewCell {
    
    let logPress = UILongPressGestureRecognizer()
    
    @IBOutlet weak var RadioImg: UIImageView!
    @IBOutlet weak var longPressViw: UIView!
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var name: UILabel!
    
    var Radio: PopularRadio!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0
        
    }
    
    
    func configureCell(_ name1: String, image: String){
        addButtonOutlet.layer.cornerRadius = self.addButtonOutlet.frame.size.width / 2
        addButtonOutlet.isHidden = true
        logPress.addTarget(self, action: #selector(PopularRadioCell.longTap( _:)))
        longPressViw.addGestureRecognizer(logPress)
        name.text = name1
        RadioImg.kf.setImage(with: URL(string: image)!, placeholder: UIImage(named: "Logo"))
    }
    
    func longTap(_ sender : UIGestureRecognizer){
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 0
                self.RadioImg.alpha = 1
                self.name.alpha = 1
            })
            addButtonOutlet.isHidden = true
            
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            addButtonOutlet.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 1
                self.RadioImg.alpha = 0.2
                self.name.alpha = 0.2
            })
        }
    }

    @IBAction func addButtonAction(_ sender: AnyObject) {
        //Poner parse...
    }
    
   
    
    
    
}
