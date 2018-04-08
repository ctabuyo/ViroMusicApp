//
//  ArtistViewController.swift
//  Viro
//
//  Created by Imac RDG on 17/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import MediaPlayer
import SCLAlertView

struct StretchyHeader2 {
    fileprivate let headerHeight: CGFloat = 210
    fileprivate let headerCut: CGFloat = 0
    
}

class ArtistViewController: UIViewController {
    //MARK: - VARIABLES
    var songs = [String]()
    var albums = [String]()
    var name : String!
    var artistID : Int!
    var image : String!
    var newHeaderLayer: CAShapeLayer!
    
    var nameForAlbum: String!
    var aNameForAlbum: String!
    var albumImage : String!
    var click = 0
    var times = 0
    var fromControl = false
    
    
    //MARK: - IB OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var realArtistName: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingViewSong: UILabel!
    @IBOutlet weak var playingViewArtist: UILabel!
    @IBOutlet weak var playingViewPlayButton: UIButton!
    @IBOutlet weak var playingViewImage: UIImageView!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        pltype = PlayerType.artist
        super.viewDidLoad()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        headerImage.kf.setImage(with: URL(string:image)!)
        realArtistName.text = name
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        updateView()
        playingViewSpinner.color = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
       NotificationCenter.default.addObserver(self, selector: #selector(ArtistViewController.stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ArtistViewController.playNext),name:NSNotification.Name(rawValue: "playNN"), object: nil)
        
        
        
        if currentSong == nil {
            playingView.isHidden = true
            
        } else {
            playingViewImage.image = currentImage
            playingViewSong.text = currentSong
            playingViewArtist.text = currentSongArtist
        }
        
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
            self.fromControl = true
            self.playNext()
            return MPRemoteCommandHandlerStatus.success
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    
    
    func playNN() {
        playNext()
    }
    
   
    
    func playNext() {
        if times == 5 {
            jukebox.stop()
        } else {
            times += 1
            if fromControl == true {
                if click < 4 && times > 1 {
                    click += 1
                }
                
            }
            if click <= 4 {
                currentSong = songs[click+1]
                currentAlbum = name
                currentImage = headerImage.image
                configurePlayingView()
                APICalls().getResults(currentAlbum!+","+currentSong!, i: 0) { () -> () in
                    APICalls().checkResult(currentSong!, Parameter: currentAlbum!+","+currentSong!, Artist: currentAlbum!) { () -> () in
                        
                    }
                }
            }
        }
        
    }
    
    func configurePlayingView() {
        playingView.isHidden = false
        playingViewSong.text = currentSong
        playingViewArtist.text = currentAlbum
        playingViewImage.image = currentImage
    }
    
    

    func updateView(){
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(headerView)
        
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        let newHeight = StretchyHeader2().headerHeight - StretchyHeader2().headerCut/2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView()
    }
    
    
    func stopAnimating() {
        playingViewSpinner.stopAnimating()
    }
    
    
    func setNewView(){
        
        let newHeight = StretchyHeader2().headerHeight - StretchyHeader2().headerCut/2
        var getHeaderFrame =  CGRect(x: 0, y: -newHeight, width: view.bounds.width, height: StretchyHeader2().headerHeight)
        
        if tableView.contentOffset.y < newHeight {
            
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader2().headerCut/2
        }
        
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader2().headerCut))
        newHeaderLayer.path = cutDirection.cgPath
        
        
        
        
    }
    
    
    @IBAction func goToNowPlaying(_ sender: AnyObject) {
       performSegue(withIdentifier: "goToNPArtist", sender: nil)
    }
    
    @IBAction func playButton(_ sender: AnyObject) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAlbum2" {
            if let newvc = segue.destination as? AlbumViewController {
                newvc.canciones = iTunesAPI().removeDuplicates(APTNames)
                newvc.name = nameForAlbum
                newvc.Artistname = realArtistName.text
                newvc.Image = albumImage
                newvc.images = APTImages
                newvc.artist = APTArtist
                type = typesAlbumVC.ArtistVC
            }
        } else if segue.identifier == "goToNPArtist" {
            if let newvc = segue.destination as? NowPlayingViewController {
                newvc.name = currentSong
                newvc.Image = "http://google.es"
                newvc.imageII = playingViewImage.image
                newvc.artistName = currentAlbum
            }
        }
    }
}
  



extension ArtistViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count + albums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row <= 4{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Artist1Cell", for: indexPath) as! Artist1TableViewCell
        cell.configureCell((indexPath as NSIndexPath).row + 1, songName: songs[(indexPath as NSIndexPath).row])
        return cell
        }else if (indexPath as NSIndexPath).row == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Artist2Cell", for: indexPath) as! Artist2TableViewCell
            
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        click = (indexPath as NSIndexPath).row
        currentSong = songs[(indexPath as NSIndexPath).row]
        currentAlbum = name
        currentImage = headerImage.image
        configurePlayingView()
            APICalls().getResults(currentAlbum!+","+currentSong!, i: 0) { () -> () in
                APICalls().checkResult(currentSong!, Parameter: currentAlbum!+","+currentSong!, Artist: currentAlbum!) { () -> () in
                    
                }
            }
        
        
    }
    



    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row <= 4{
            guard cell is Artist1TableViewCell else { return }
        }else if (indexPath as NSIndexPath).row == 5{
        
        guard let tableViewCell = cell as? Artist2TableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard cell is Artist2TableViewCell else { return }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row <= 4{
            return 54
        }else if (indexPath as NSIndexPath).row == 5{
            return 264
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension ArtistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCollectionViewCell
        cell.configureCell(albums[(indexPath as NSIndexPath).item], Img: ImagesArtist[(indexPath as NSIndexPath).row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        iTunes().getAlbums(AlbumColId[(indexPath as NSIndexPath).row]) { () -> () in
            self.playingViewSpinner.startAnimating()
            self.nameForAlbum = self.albums[(indexPath as NSIndexPath).row]
            self.aNameForAlbum = self.artistName.text!
            self.albumImage = ImagesArtist[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "goToAlbum2", sender: nil)
        }
    }
    
}

extension ArtistViewController :  UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }
    
}

