//
//  AlbumViewController.swift
//  Viro
//
//  Created by Imac RDG on 15/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Jukebox
import MediaPlayer
import SCLAlertView

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (unshuffledCount, firstUnshuffled) in zip(stride(from: c, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class AlbumViewController: UIViewController {
    //MARK: - VARIBALES
    var canciones = [String]()
    var artist = [String]()
    var images = [String]()
    var links = [String]()
    var name: String!
    var Artistname: String!
    var mode = ""
    var Image: String!
    var ImageForNowPlaying: String!
    
    var ArtistNameSt : String!
    var ArtistImageSt : String!
    
    var indexForCP = 0
    
    var playingIndex : Int!
    
    var songsForShuffle = [String]()
    var linksForShuffle = [String]()
    
    var dictionary = [String : (String,String,String)]()
    var shuffledDictionary : [(String, (String,String,String))]!
    var NormalDictionary : [(String, (String,String,String))]!
    
    
    
    
    var shuffleMode = false

    //MARK: - IB OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var albumImagevIew: UIImageView!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var artistBtnOutlet: UIButton!
    @IBOutlet weak var albumNameLbl: UILabel!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingViewSong: UILabel!
    @IBOutlet weak var playingViewArtist: UILabel!
    @IBOutlet weak var playingViewImg: UIImageView!
    @IBOutlet weak var playingViewBtn: UIButton!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isHidden = true
        containerView.alpha = 0
        UIApplication.shared.beginReceivingRemoteControlEvents()
        albumNameLbl.text = name
        
        playingViewSpinner.color = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        albumImagevIew.kf.setImage(with: URL(string:Image)!, placeholder: UIImage(named: "Logo"))
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController().wantedToAdd),name:NSNotification.Name(rawValue: "wantedToAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.cancelPressed),name:NSNotification.Name(rawValue: "cancelButtonPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.cancelPressed),name:NSNotification.Name(rawValue: "playlistHasBeenPosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.cancelPressed),name:NSNotification.Name(rawValue: "songHasBeenPosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.continuePlaying),name:NSNotification.Name(rawValue: "continuePAB"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.playPlayedSong),name:NSNotification.Name(rawValue: "continuePPS"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
        
        
        
        if mode == "Playlist" || mode == "Charts" {
            artistBtnOutlet.setTitle(Artistname+">", for: UIControlState())
            artistBtnOutlet.isEnabled = false
        } else {
            Artistname = artist[0]
            artistBtnOutlet.setTitle(Artistname+">", for: UIControlState())
        }
        
        if currentSong == nil {
            playingView.isHidden = true
            
        } else {
            playingViewSong.text = currentSong
            playingViewImg.image = currentImage
            playingViewArtist.text = currentAlbum
            
        }
        
        
        pltype = PlayerType.album
        if canciones[0] == "" {
            canciones.remove(at: 0)
        }
        for (i, _) in canciones.enumerated() {
            if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts {
              dictionary[canciones[i]] = ("hello",artist[i],images[i])
              
            } else if type == typesAlbumVC.SearchAlbum {
              dictionary[canciones[i]] = ("",artist[i],images[i])
            } else if type == typesAlbumVC.ArtistVC {
               dictionary[canciones[i]] = ("",artist[0],Image)
            } else{
              dictionary[canciones[i]] = (links[i],artist[i],images[i])
            }
            
            
            
        }
        
        print(dictionary)
        animations()
        shuffledDictionary = dictionary.shuffled()

        // Do any additional setup after loading the view.
        
        // Handle on locked-screen
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            jukebox.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.playCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            jukebox.play()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.togglePlayPauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            if jukebox.state == .playing {
                jukebox.pause()
            } else {
                jukebox.play()
            }
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.nextTrackCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.continuePlaying()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.previousTrackCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            if let h = jukebox.currentItem?.currentTime {
                let temp:Int = Int((h))
                let secs:Int = temp % 60
                if secs >= 6 {
                    jukebox.seek(toSecond: Int(0.0))

                } else {
                  self.playPlayedSong()
                }
            }
            return MPRemoteCommandHandlerStatus.success
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    //MARK: - MY FUNCTIONS
    
    
    func cancelPressed(){
        UIView.animate(withDuration: 0.3, animations: {
            
            self.containerView.alpha = 0
            self.tableView.alpha = 1
            self.containerView.isHidden = false
        })
        
    }
    
    func stopAnimating() {
        playingViewSpinner.stopAnimating()
    }
    
    
    
    
    func configurePlaying() {
        if currentSong == nil
        {
            playingView.isHidden = true
        }else{
            playingView.isHidden = false
            playingViewSong.text = currentSong
            playingViewArtist.text = currentAlbum
        }
        
        if isPlaying == true{
            
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        }else{
            
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
            
        }
    }

    func playPlayedSong() {
        
        indexForCP = indexForCP - 1
        if shuffleMode == true {
            if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum {
                isPlaying = true
                currentSong = ("\(shuffledDictionary[indexForCP].0)")
                currentAlbum = shuffledDictionary[indexForCP].1.1
                currentSongArtist = shuffledDictionary[indexForCP].1.1
                let newVar = shuffledDictionary[indexForCP].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                ImageForNowPlaying = newVar
                self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                        currentImage = Image
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
                })
                configurePlaying()
                searchSYT().getResults(currentSongArtist!+","+currentSong!, i:0) { () -> () in
                    searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                        
                    }
                }
                
            } else {
                isPlaying = true
                currentSong = ("\(shuffledDictionary[indexForCP].0)")
                currentAlbum = shuffledDictionary[indexForCP].1.1
                currentSongArtist = shuffledDictionary[indexForCP].1.1
                let newVar = shuffledDictionary[indexForCP].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                ImageForNowPlaying = newVar
                self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                        currentImage = Image
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
                })
                configurePlaying()
                let Link = shuffledDictionary[indexForCP].1.0
                print("This is the link \(Link)")
                searchSYT().downloadData(Link) { () -> () in
                    if let h = YTSURL as String! {
                        URL12 = h
                        Player.sharedInstance.play(h)
                    }
                }
                
            }
  
        } else {
            tableView.selectRow(at: IndexPath(row: indexForCP, section: 0), animated: false, scrollPosition: .none)
            if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum {
                isPlaying = true
                currentSong = ("\(canciones[indexForCP])")
                currentAlbum = artist[indexForCP]
                currentSongArtist = artist[indexForCP]
                let newVar = images[indexForCP].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                ImageForNowPlaying = newVar
                self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "musicintro"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                        currentImage = Image
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
                })
                configurePlaying()
                searchSYT().getResults(currentSongArtist!+","+currentSong!, i:0) { () -> () in
                    searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                        
                    }
                }
            } else {
                isPlaying = true
                currentSong = ("\(canciones[indexForCP])")
                currentAlbum = artist[indexForCP]
                currentSongArtist = artist[indexForCP]
                let newVar = images[indexForCP].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                ImageForNowPlaying = newVar
                self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                        currentImage = Image
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
                })
                configurePlaying()
                let Link = links[indexForCP]
                print("This is the link \(Link)")
                searchSYT().downloadData(Link) { () -> () in
                    if let h = YTSURL as String! {
                        URL12 = h
                        Player.sharedInstance.play(h)
                        
                        
                    }
                }
            }  
        }
        

        
    }
    
    
    func wantedToAdd(){
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            
            self.containerView.alpha = 1
            self.tableView.alpha = 0.1
        })
        
    }
    
    
    func continuePlaying() {
        if indexForCP < canciones.count{
            indexForCP = indexForCP + 1
        }
        
        if indexForCP == canciones.count {
            jukebox.stop()
        } else {
            if shuffleMode == true {
                if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum  {
                    isPlaying = true
                    currentSong = ("\(shuffledDictionary[indexForCP].0)")
                    currentAlbum = shuffledDictionary[indexForCP].1.1
                    currentSongArtist = shuffledDictionary[indexForCP].1.1
                    let newVar = shuffledDictionary[indexForCP].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                    ImageForNowPlaying = newVar
                    self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        if let Image = image {
                            currentImage = Image
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                        }
                        
                    })
                    configurePlaying()
                    searchSYT().getResults(currentSongArtist!+","+currentSong!, i:0) { () -> () in
                        searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                            
                        }
                    }
                    
                    
                    
                } else {
                    isPlaying = true
                    currentSong = ("\(shuffledDictionary[indexForCP].0)")
                    currentAlbum = shuffledDictionary[indexForCP].1.1
                    currentSongArtist = shuffledDictionary[indexForCP].1.1
                    let newVar = shuffledDictionary[indexForCP].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                    ImageForNowPlaying = newVar
                    self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        if let Image = image {
                            currentImage = Image
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                        }
                        
                    })
                    configurePlaying()
                    let Link = shuffledDictionary[indexForCP].1.0
                    print("This is the link \(Link)")
                    let number = dataFromParse.playedSongs + 1
                    ParseAPIManager().postPlayedSong(value: number)
                    searchSYT().downloadData(Link) { () -> () in
                        if let h = YTSURL as String! {
                            URL12 = h
                            Player.sharedInstance.play(h)
                        }
                    }
                    
                }
                
            } else {
                tableView.selectRow(at: IndexPath(row: indexForCP, section: 0), animated: false, scrollPosition: .none)
                print("This is the shit \(type)")
                if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum {
                    isPlaying = true
                    currentSong = ("\(canciones[indexForCP])")
                    currentAlbum = artist[indexForCP]
                    currentSongArtist = artist[indexForCP]
                    let newVar = images[indexForCP].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                    ImageForNowPlaying = newVar
                    self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        if let Image = image {
                            currentImage = Image
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                        }
                        
                    })
                    configurePlaying()
                    if dataFromParse.isPremium == false {
                        searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                            
                        }
                        
                    } else if type == typesAlbumVC.HomePlaylist {
                        isPlaying = true
                        currentSong = ("\(canciones[indexForCP])")
                        currentAlbum = artist[indexForCP]
                        currentSongArtist = artist[indexForCP]
                        let newVar = images[indexForCP].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
                        ImageForNowPlaying = newVar
                        self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            if let Image = image {
                                currentImage = Image
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                            }
                            
                        })
                        configurePlaying()
                        let Link = links[indexForCP]
                        print("This is the link \(Link)")
                        searchSYT().downloadData(Link) { () -> () in
                            if let h = YTSURL as String! {
                                URL12 = h
                                Player.sharedInstance.play(h)
                            }
                        }
                    }
                }
            }
        }
    }
    

        
                           
                        
                    

                    
                    
                    
                
            

                
         
    
    
    func play(_ Artist: String, Song: String, completed: @escaping DownloadComplete) {
        APICalls().getResults(Artist+","+Song, i: 0) { () -> () in
            APICalls().checkResult(Song, Parameter: Artist+","+Song, Artist: Artist) { () -> () in
               
                completed()
            }
        }
        
    }
    

    

    
    func animations(){
        self.albumImagevIew.center.x = -self.view.frame.width-30
        self.albumNameLbl.center.x = self.view.frame.width + 30
        self.artistBtnOutlet.center.x = self.view.frame.width + 30
        self.playButtonOutlet.center.x = self.view.frame.width + 30
        self.backgroundLabel.center.x = -self.view.frame.width-30
        
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.albumImagevIew.center.x = self.view.frame.width / 2
            
            }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.backgroundLabel.center.x = self.view.frame.width / 2
            
            }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.1, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.albumNameLbl.center.x = self.view.frame.width / 2
            
            }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.artistBtnOutlet.center.x = self.view.frame.width / 2
            
            }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.4, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.playButtonOutlet.center.x = self.view.frame.width / 2
            
            }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "goToArtist2" {
          if let newvc = segue.destination as? ArtistViewController {
          newvc.image = ArtistImageSt
          newvc.albums = iTunesAPI().removeDuplicates(AlbumsArtist)
          newvc.songs =  iTunesAPI().removeDuplicates(TracksArtist)
          newvc.name = ArtistNameSt
        }
       } else if segue.identifier == "goToNowPlaying3" {
        if let newvc = segue.destination as? NowPlayingViewController {
            let name = playingViewSong.text
            newvc.name = name
            newvc.Image = ImageForNowPlaying
            newvc.imageII = playingViewImg.image
            newvc.artistName = currentSongArtist
        }

        }
    }
    
    
    
    @IBAction func goToArtist(_ sender: AnyObject) {
        ArtistNameSt = Artistname
        ArtistImageSt = Image
        iTunes().getTracks(Artistname) { () -> () in
            artistData().getAlbums(ArtistID[0]){ () -> () in
                artistData().getTracks(self.Artistname){ () -> () in
                    self.performSegue(withIdentifier: "goToArtist2", sender: nil)
                    
                }
            }
        }
        

    }
    
    @IBAction func startPlaying(_ sender: AnyObject) {
        shuffleMode = true
        playingViewSpinner.startAnimating()
        if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum  {
            isPlaying = true
            currentSong = ("\(shuffledDictionary[0].0)")
            currentAlbum = shuffledDictionary[0].1.1
            currentSongArtist = shuffledDictionary[0].1.1
            let newVar = shuffledDictionary[0].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
            ImageForNowPlaying = newVar
            self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
                configurePlaying()
                searchSYT().getResults(currentSongArtist!+","+currentSong!, i:0) { () -> () in
                    searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                        
                    }
                }
            
            
            

        } else {
            isPlaying = true
            currentSong = ("\(shuffledDictionary[0].0)")
            currentAlbum = shuffledDictionary[0].1.1
            currentSongArtist = shuffledDictionary[0].1.1
            let newVar = shuffledDictionary[0].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
            ImageForNowPlaying = newVar
            self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
            
            configurePlaying()
            let Link = shuffledDictionary[0].1.0
            print("This is the link \(Link)")
                searchSYT().downloadData(Link) { () -> () in
                    if let h = YTSURL as String! {
                        URL12 = h
                        Player.sharedInstance.play(h)
                    }
                }
           
        }
        
        
        
    }
    
    @IBAction func pause(_ sender: AnyObject) {
        if jukebox.state == .playing{
            jukebox.pause()
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
            isPlaying = false
        } else {
            jukebox.play()
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
            isPlaying = true
        }
    }
    
    @IBAction func goToNowPlaying(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "goToNowPlaying3", sender: nil)
    }
    

}

extension AlbumViewController : UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canciones.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumTableViewCell
        cell.configureCell((indexPath as NSIndexPath).row + 1, songName: canciones[(indexPath as NSIndexPath).row], artistName: Artistname, image: Image)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shuffleMode = false
        indexForCP = indexPath.row
        playingViewSpinner.startAnimating()
        if type == typesAlbumVC.HomeAlbum || type == typesAlbumVC.HomeCharts || type == typesAlbumVC.SearchAlbum || type == typesAlbumVC.ArtistVC  {
            isPlaying = true
            currentSong = ("\(canciones[indexPath.row])")
            currentAlbum = artist[indexPath.row]
            currentSongArtist = artist[indexPath.row]
            let newVar = images[indexPath.row].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
            ImageForNowPlaying = newVar
            self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
            configurePlaying()
                searchSYT().getResults(currentSongArtist!+","+currentSong!, i:0) { () -> () in
                    searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                        
                    }
                }
  
            
            
        } else if type == typesAlbumVC.HomePlaylist {
            isPlaying = true
            currentSong = ("\(canciones[indexPath.row])")
            currentAlbum = artist[indexPath.row]
            currentSongArtist = artist[indexPath.row]
            let newVar = images[indexPath.row].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
            ImageForNowPlaying = newVar
            self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
            configurePlaying()
            let Link = links[indexPath.row]
            print("This is the link \(Link)")
                searchSYT().downloadData(Link) { () -> () in
                    if let h = YTSURL as String! {
                        URL12 = h
                        Player.sharedInstance.play(h)
                    }
                }
        }

    }
}
