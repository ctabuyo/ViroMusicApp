//
//  NowPlayingViewController.swift
//  Biro
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import AVFoundation
import Jukebox
import Pulsator
import MediaPlayer
import SCLAlertView

class NowPlayingViewController: UIViewController {
    
    //LOCALIZABLE VARIABLES
    let streamingTitle = NSLocalizedString("streaming_title", comment: "")
    
    //MARK: - IB OUTLETS
    
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btn2outlet: UIButton!
    @IBOutlet weak var btn1outlet: UIButton!
    @IBOutlet weak var moreBtnOutlet: UIButton!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var pauseButtonOutlet: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timerLbl1: UILabel!
    @IBOutlet weak var timerLbl2: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var viewForCenter: UIView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForthButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var albumConstraint: NSLayoutConstraint!
    
    //MARK: - VARIABLES
    var name: String?
    var Image: String?
    var imageII : UIImage?
    var count = 0
    var timer = Timer()
    var artistName : String?
    let pulsator = Pulsator()
    var isAnimationPlaying = false
    var isTouched = false

    var repeatMode = false
    
    //var player: AVPlayer!
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isHidden = true
        containerView.alpha = 0
        btn1outlet.isHidden = true
        btn1outlet.alpha = 0
        btn2outlet.alpha = 0
        btn2outlet.isHidden = true
      slider.minimumValue = 0.0
      slider.maximumValue = 100.0
      doMath()
      albumCoverImage.layer.masksToBounds = true
      NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.modifyNP),name:NSNotification.Name(rawValue: "modifyNP"), object: nil)
      Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NowPlayingViewController().doMath), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.cancelPressed),name:NSNotification.Name(rawValue: "songHasBeenPosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.cancelPressed),name:NSNotification.Name(rawValue: "cancelButtonPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.cancelPressed),name:NSNotification.Name(rawValue: "playlistHasBeenPosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.updateInfo),name:NSNotification.Name(rawValue: "updateSongInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NowPlayingViewController.updateInfo2),name:NSNotification.Name(rawValue: "updateSongInfo2"), object: nil)
      albumCoverImage.image = imageII
      songNameLbl.text = name
      artistLbl.text = artistName
      //albumCoverImage.setImageWithUrl(NSURL(string: Image!)!, placeHolderImage: UIImage(named: "oldradio"))
        configurePlaying()
        

        if pltype == PlayerType.Radio {
            goForthButton.isEnabled = false
            goBackButton.isEnabled = false
            btn1outlet.isEnabled = false
            btn2outlet.isEnabled = false
            slider.isEnabled = false
            if let h = jukebox.currentItem?.meta.title {
                artistLbl.text = h
            } else {
                artistLbl.text = streamingTitle
            }
        }
        let deviceHeight = self.view.bounds.height
        if deviceHeight == 480{
            albumConstraint.constant = -150
        }
    }
    
    
    
    func doMath() {
        if pltype != PlayerType.Radio {
            if let h = jukebox.currentItem?.currentTime, let n = jukebox.currentItem?.meta.duration {
                slider.isEnabled = true
                let temp:Int = Int((h))
                let mins:Int = temp / 60
                let secs:Int = temp % 60
                let string1 = String(format: "%02d", secs)
                timerLbl1.text = String("\(mins):\(string1)")
                
                let temp2: Int = Int((n) - (h))
                let mins2:Int = temp2 / 60
                let secs2:Int = temp2 % 60
                let string2 = String(format: "%02d", secs2)
                timerLbl2.text =  String("\(mins2):\(string2)")
                
                
                slider.value = Float((100 * (h)) / (n))
                
            } else {
              timerLbl1.text = String("00:00")
              timerLbl2.text =  String("00:00")
              slider.isEnabled = false
            }
  
        } else {
            timerLbl1.text = String("00:00")
            timerLbl2.text = String("∞")
        }
        
        if repeatMode == true {
          if let h = jukebox.currentItem?.currentTime, let n = jukebox.currentItem?.meta.duration {
            let subtraction = n - h
            print(subtraction)
            if subtraction < 3.0 {
                jukebox.seek(toSecond: Int(1.0))
              }
            }
        }
        
    }
    
    func cancelPressed(){
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.white
            self.containerView.alpha = 0
            self.containerView.isHidden = true
            self.albumCoverImage.alpha = 1
            self.btn2outlet.alpha = 1
            self.moreBtnOutlet.alpha = 1
            self.btn1outlet.alpha = 1
            self.generalView.alpha = 1
        })
        
    }
    
    func wantedToAdd(){
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.darkGray
            self.containerView.alpha = 1
            self.albumCoverImage.alpha = 0.1
            self.btn2outlet.alpha = 0.1
            self.moreBtnOutlet.alpha = 0.1
            self.btn1outlet.alpha = 0.1
            self.generalView.alpha = 0.1
            
        })
        animations()
    }
    
    func animations(){
        self.containerView.center.x = -self.view.frame.width-200
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.containerView.center.x = self.view.frame.width / 2
            
            }, completion: nil)
    }
    
    func updateInfo() {
      albumCoverImage.image = currentImage
        songNameLbl.text = currentSong
        artistLbl.text = currentSongArtist
    }
    
    func updateInfo2() {
        if pltype == PlayerType.Radio {
            if let h = jukebox.currentItem?.meta.title {
                artistLbl.text = h
            } else {
                artistLbl.text = streamingTitle
            }
        }
        
    }

    
    func modifyNP() {
        songNameLbl.text = currentSong
        artistLbl.text = currentAlbum
        albumCoverImage.image = currentImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pulseAnimation()
    }
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        volumeView.setRouteButtonImage(UIImage(named: "airplayIcon.png"), for: .normal)
        //volumeView.setMinimumVolumeSliderImage(UIImage(named: "maxSlider.png"), for: .normal)
        
        volumeView.tintColor = UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pauseButtonOutlet.layer.cornerRadius = self.pauseButtonOutlet.frame.size.width / 2
        self.pauseButtonOutlet.clipsToBounds = true
        
    }
    
    //MARK: - MY FUNCTIONS
    
    func pulseAnimation(){
        pulsator.position = pauseButtonOutlet.center
        myView.layer.insertSublayer(self.pulsator, below:
            pauseButtonOutlet.layer)
        pulsator.start()
        pulsator.numPulse = 3
        pulsator.radius = 150.0
        pulsator.backgroundColor = UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0).cgColor
     }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    func configurePlaying(){
        if jukebox.state == .paused{
            currentPLayer.play()
            pauseButtonOutlet.setImage(UIImage(named: "ic_play_arrow_white_36pt"), for: UIControlState())
            
        }else{
            currentPLayer.pause()
            pauseButtonOutlet.setImage(UIImage(named: "ic_pause_white_36pt"), for: UIControlState())
        
        }
    
    }
    //MARK: - IB ACTIONS
    
    @IBAction func pauseButton(_ sender: AnyObject) {
        pulsator.stop()
        if jukebox.state == .playing {
            jukebox.pause()
            pauseButtonOutlet.setImage(UIImage(named: "ic_play_arrow_white_36pt"), for: UIControlState())
            isPlaying = false
            
            
        } else {
            jukebox.play()
            pauseButtonOutlet.setImage(UIImage(named: "ic_pause_white_36pt"), for: UIControlState())
            pulseAnimation()
            isPlaying = true
        }
    }
    
    
    @IBAction func moreButtonAction(_ sender: AnyObject) {
        if isTouched == false{
            btn1outlet.isHidden = false
            btn2outlet.isHidden = false
            UIView.animate(withDuration: 0.6, animations: {
                self.btn1outlet.alpha = 1
                self.btn2outlet.alpha = 1
                self.moreBtnOutlet.setImage(#imageLiteral(resourceName: "ic_close_white"), for: UIControlState())
            })
            isTouched = true
        }else{
            isTouched = false
            UIView.animate(withDuration: 0.4, animations: {
                self.btn1outlet.alpha = 0
                self.btn2outlet.alpha = 0
                self.moreBtnOutlet.setImage(#imageLiteral(resourceName: "ic_more_horiz_white"), for: UIControlState())
            })
            delay(0.4){
                self.btn1outlet.isHidden = true
                self.btn2outlet.isHidden = true
            }
        }
    }
    
    @IBAction func addButtonAction(_ sender: AnyObject) {
        wantedToAdd()
        let data = [songNameLbl.text!, artistLbl.text!, Image]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "musicData2"), object: data)
    }

    @IBAction func repeatButtonAction(_ sender: AnyObject) {
        if repeatMode == false {
            repeatMode = true
            repeatButton.setImage(UIImage(named: "repeat_blue_48x48"), for: .normal)
        } else {
            repeatMode = false
            repeatButton.setImage(UIImage(named: "repeat_white_48x48"), for: .normal)
        }
    }
   
    @IBAction func backButtonAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func adjustTime(_ sender: UISlider) {
        jukebox.seek(toSecond: ( Int((sender.value * Float((jukebox.currentItem?.meta.duration)!)) / 100)))
    }
    @IBAction func playNextSong(_ sender: AnyObject) {
        if pltype == PlayerType.album {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "continuePAB"), object: nil)
            albumCoverImage.image = currentImage
            songNameLbl.text = currentSong
            artistLbl.text = currentSongArtist
        } else if pltype == PlayerType.playlist {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "continueP"), object: nil)
            albumCoverImage.image = currentImage
            songNameLbl.text = currentSong
            artistLbl.text = currentSongArtist
        } 
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
    }
    
    @IBAction func playPreviousSong(_ sender: AnyObject) {
        if pltype == PlayerType.album {
            if let h = jukebox.currentItem?.currentTime {
                let temp:Int = Int((h))
                let secs:Int = temp % 60
                if secs >= 6 {
                   jukebox.seek(toSecond: Int(0.0))
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "continuePPS"), object: nil)
                    albumCoverImage.image = currentImage
                    songNameLbl.text = currentSong
                    artistLbl.text = currentSongArtist
                }
            }
            
        } else if pltype == PlayerType.playlist {
            if let h = jukebox.currentItem?.currentTime {
                let temp:Int = Int((h))
                let secs:Int = temp % 60
                if secs >= 6 {
                  jukebox.seek(toSecond: Int(0.0))
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "pPlayed"), object: nil)
                    albumCoverImage.image = currentImage
                    songNameLbl.text = currentSong
                    artistLbl.text = currentSongArtist
                }
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
    }
    
}
