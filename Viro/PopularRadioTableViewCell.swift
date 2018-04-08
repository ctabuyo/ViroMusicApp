//
//  PopularRadioTableViewCell.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 12/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//


import UIKit

class PopularRadioTableViewCell: UITableViewCell {
    
    
   
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        
    }
    
    func configureCell(_ text: String) {
        name.text = text
        
    }
    
    
}
