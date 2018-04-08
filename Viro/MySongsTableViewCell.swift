//
//  MySongsTableViewCell.swift
//  Viro
//
//  Created by Imac RDG on 18/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class MySongsTableViewCell: FoldingCell {
    let logPress = UILongPressGestureRecognizer()
    var playlistIndex1: Int!
    var songIndex1: Int!
    var imageLink:String?
    var isSongFromPlaylist1: Bool!
    var Index: Int!

    @IBOutlet weak var artistBtnOutlet: UIButton!
    @IBOutlet weak var songLbl2: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var mainBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ song: String, album: String, image: String, songIndex: Int, playlistIndex: Int, isPlaylist: Bool){
        songLbl.text = song
        artistLbl.text = album
        songLbl2.text = song
        imageLink = image
        artistBtnOutlet.setTitle("\(album) >", for: UIControlState())
        albumImage.kf.setImage(with: URL(string: image)!, placeholder: UIImage(named: "Logo"))
        logPress.addTarget(self, action: #selector(MySongsTableViewCell.longTap(_:)))
        mainBtnOutlet.addGestureRecognizer(logPress)
        isSongFromPlaylist1 = isPlaylist
        songIndex1 = songIndex
        playlistIndex1 = playlistIndex
        
        
    }
    
    func configureCellDFPL(_ song: String, album: String, Image: String,  Index: Int) {
        songLbl.text = song
        artistLbl.text = album
        songLbl2.text = song
        imageLink = Image
        artistBtnOutlet.setTitle("\(album) >", for: UIControlState())
        albumImage.kf.setImage(with: URL(string: Image)!, placeholder: UIImage(named: "Logo"), completionHandler: {
            (image, error, cacheType, imageUrl) in
            if let Image = image {
                currentImage = Image
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
            }
            
        })
        self.Index = Index
    }
    
    func longTap(_ sender : UIGestureRecognizer){
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            /*UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 0
                self.radioImagView.alpha = 1
                self.nameLbl.alpha = 1
            })*/
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "wantedToAdd1"), object: nil)
            let data = [songLbl.text!, artistLbl.text!, imageLink]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicData1"), object: data)
            //ParseAPIManager().checkAndPost(nameLbl.text!, albumName: artist1)
        
            /*UIView.animate(withDuration: 0.3, animations: {
                
                self.addButtonOutlet.alpha = 1
                self.radioImagView.alpha = 0.1
                self.nameLbl.alpha = 0.1
            })*/
        }
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

    @IBAction func playButton1(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "startAnimating"), object: nil)
        print("button touched")
        let dic = ["Index": songIndex1]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setIndex"), object: nil, userInfo: dic)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sMOD"), object: nil)
        isPlaying = true
        currentSong = songLbl.text!
        currentAlbum = artistLbl.text!
        currentSongArtist = artistLbl.text!
        currentImage = albumImage.image!
        NotificationCenter.default.post(name: Notification.Name(rawValue: "confVW"), object: nil)
        if dataFromParse.isPremium == false {
            if dataFromParse.playedSongs <= 15 {
                searchSYT().getResults(artistLbl.text!+","+songLbl.text!, i:0) { () -> () in
                    searchSYT().checkResult(self.songLbl.text!, Parameter: self.artistLbl.text!+","+self.songLbl.text!, Artist: self.artistLbl.text!) { () -> () in
                        
                        
                    }
                }
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showAlertIAP"), object: nil)
               
            }
        } else {
            searchSYT().getResults(artistLbl.text!+","+songLbl.text!, i:0) { () -> () in
                searchSYT().checkResult(self.songLbl.text!, Parameter: self.artistLbl.text!+","+self.songLbl.text!, Artist: self.artistLbl.text!) { () -> () in
                    
                    
                }
            }
        }
        
    }
    @IBAction func playButton2(_ sender: AnyObject) {
        
        let dic = ["Index": songIndex1]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setIndex"), object: nil, userInfo: dic)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sMOD"), object: nil)
        isPlaying = true
        currentSong = songLbl.text!
        currentAlbum = artistLbl.text!
        currentSongArtist = artistLbl.text!
        currentImage = albumImage.image!
        NotificationCenter.default.post(name: Notification.Name(rawValue: "confVW"), object: nil)
        if dataFromParse.isPremium == false {
            if dataFromParse.playedSongs <= 15 {
                searchSYT().getResults(artistLbl.text!+","+songLbl.text!, i:0) { () -> () in
                    searchSYT().checkResult(self.songLbl.text!, Parameter: self.artistLbl.text!+","+self.songLbl.text!, Artist: self.artistLbl.text!) { () -> () in
                        
                        
                    }
                }
            } else {
              NotificationCenter.default.post(name: Notification.Name(rawValue: "showAlertIAP"), object: nil)
            }
        } else {
            searchSYT().getResults(artistLbl.text!+","+songLbl.text!, i:0) { () -> () in
                searchSYT().checkResult(self.songLbl.text!, Parameter: self.artistLbl.text!+","+self.songLbl.text!, Artist: self.artistLbl.text!) { () -> () in
                    
                    
                }
            }
        }
        
    }

    @IBAction func deleteButton(_ sender: AnyObject) {
        ParseAPIManager().deleteSongs(isSongFromPlaylist1, playlistIndex: playlistIndex1, songIndex: songIndex1)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "songDeleted"), object: nil)
    }
}


