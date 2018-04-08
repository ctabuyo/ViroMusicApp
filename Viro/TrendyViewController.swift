//  TrendyViewController.swift
//  Biro
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import MediaPlayer
import Jukebox
import Kingfisher
import SCLAlertView
import Parse


struct StretchyHeader1 {
    fileprivate let headerHeight1: CGFloat = 210
    fileprivate let headerCut1: CGFloat = 0
    
}

class TrendyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - LOCALIZABLE VARIABLES
    let noAccIAPErrorTitle = NSLocalizedString("noacc_iap_err_title", comment: "")
    let noAccIAPError = NSLocalizedString("noacc_iap_err", comment: "")
    let noAlbumTitle = NSLocalizedString("noalbum_title", comment: "")
    let noAlbum = NSLocalizedString("noalbum", comment: "")
    let successTitle = NSLocalizedString("bought_success_title", comment: "")
    let success = NSLocalizedString("bought_success", comment: "")
    let buyViroMesssage = NSLocalizedString("buy_Viro_Message", comment: "")
    let TSingles = NSLocalizedString("TSingles", comment: "")
    let TAlbums = NSLocalizedString("TAlbums", comment: "")
    let Charts = NSLocalizedString("Charts", comment: "")
    let Playlists = NSLocalizedString("Playlists", comment: "")
    
    //  MARK: - IB OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playingViewSongName: UILabel!
    @IBOutlet weak var playingViewArtistName: UILabel!
    @IBOutlet weak var playingViewImg: UIImageView!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingViewBtn: UIButton!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var IAPIndicator: UIActivityIndicatorView!
    @IBOutlet weak var IAPView: UIView!

   
    
    //MRK: - VARIABLES
    var browse = [""]
    var charts = ["Top 40 - USA", "Top 40 - UK", "Top 40 - Spain", "Top 40 - Australia", "Top 40 - Hong Kong", "Top 40 - Nigeria"]
    var chartsImages = ["http://i.imgur.com/FcILsJl.jpg", "http://mmbiz.qpic.cn/mmbiz/8wjicwSuvUtaGdj1WcceOAqB6FqK5WITib5VJnPt8U0eIOI9qT03pBgDK1XoHCfRzuAwpibMt9UA0yNfNXhgKYDLQ/0", "https://pp.vk.me/c618228/v618228457/6a24/rEcFVHaVfB4.jpg", "http://www.ariacharts.com.au/App_Themes/WWW_Charts.Main/images/logo@3x.png", "http://a3.mzstatic.com/us/r30/Purple6/v4/62/c2/25/62c225a1-6d00-21a6-35ec-59d8958a8425/icon175x175.jpeg", "http://toyeenbalogun.com/wp-content/uploads/2015/05/Nigeria.jpg"]
    var countryCharts = ["us","gb","es","au","hk","ng"]
    var artistForAlbumCH = ""
    var imageForAlbumCH = ""
    var artistForAlbumVC = ""
    
    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    var indexForMM : Int!
    
    var toAlbumVC : String!
    
    var downloaded = false
    
    var playListSongs = [String]()
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        browse = [TSingles, TAlbums, Charts, Playlists]
        pltype = PlayerType.Trendy
        Player.sharedInstance.setDelegate()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        tabBarController?.tabBar.tintColor = UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0)
        super.viewDidLoad()
        URLCache.shared.removeAllCachedResponses()
        NotificationCenter.default.addObserver(self, selector: #selector(TrendyViewController.loadList(_:)),name:NSNotification.Name(rawValue: "load3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrendyViewController().stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrendyViewController().configureButton),name:NSNotification.Name(rawValue: "mySongsLoadedTrendy"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrendyViewController().showAlertNoAlbum),name:NSNotification.Name(rawValue: "couldntLoadAlbum"), object: nil)
        playingViewSpinner.color = UIColor(red: 239.0/255.0, green: 72.0/255.0 , blue: 155.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        trendingSingles().downloadPlaylist()
        trendingSingles().downloadTrendingSingles() { () -> () in
            self.tableView.reloadData()
        }
        trendingSingles().getAlbums() { () -> () in
            self.tableView.reloadData()
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        self.tableView.reloadData()
        updateView()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ParseAPIManager().getParseData()
        if currentSong == nil {
            playingView.isHidden = true
            
        } else {
            playingView.isHidden = false
            playingViewSongName.text = currentSong
            playingViewImg.image = currentImage
            playingViewArtistName.text = currentAlbum
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    func configureButton() {
        if UserDefaults.standard.bool(forKey: "IRuleTheWorld") == true {
            ParseAPIManager().postPremium(value: true)
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }

        downloaded = true
        if dataFromParse.isPremium == true {
            ParseAPIManager().postInstallationPremium(value: true)
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        } else {
            
        }
    }
    
    
    
    
    //MARK: - MY FUNCTIONS
    func showAlertNoAccount() {
        let alertView = SCLAlertView()
        alertView.showError(noAccIAPErrorTitle, subTitle: noAccIAPError)
    }
    
    func showAlertNoAlbum() {
        let alertView = SCLAlertView()
        alertView.showError(noAlbumTitle, subTitle: noAlbum)
    }
    

    func showAlertVCR(){
        let alertView = SCLAlertView()
        alertView.showSuccess(successTitle, subTitle: success)
        
        
    }
    
    
    func configurePlayingView(){
        
        if currentSong == nil
        {
            playingView.isHidden = true
        }else{
            playingView.isHidden = false
            playingViewSongName.text = currentSong
            playingViewArtistName.text = currentAlbum
        }
        
        if isPlaying==true{
            
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        }else{
            
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
            
        }
    }
    
    
    
    func stopAnimating() {
        playingViewSpinner.stopAnimating()
    }
    
    func updateView(){
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(headerView)
        
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        let newHeight = StretchyHeader1().headerHeight1 - StretchyHeader1().headerCut1/2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView()
    }
    
    
    
    func setNewView(){
        
        let newHeight = StretchyHeader1().headerHeight1 - StretchyHeader1().headerCut1/2
        var getHeaderFrame =  CGRect(x: 0, y: -newHeight, width: view.bounds.width, height: StretchyHeader1().headerHeight1)
        
        if tableView.contentOffset.y < newHeight {
            
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader1().headerCut1/2
        }
        
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader1().headerCut1))
        newHeaderLayer.path = cutDirection.cgPath
        
        
        
        
    }
    
    @IBAction func goToNowPlayingBtn(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToNowPlayingTD", sender: nil)
    }
    
    
    
    @IBAction func pauseBtn(_ sender: AnyObject) {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlaylistTD" {
            let productDetailVC: MyMusicViewController = segue.destination as! MyMusicViewController
                productDetailVC.playlistSongs = plSongName
                productDetailVC.playlistArtist = plSongArtist
                productDetailVC.playlistSongsImages = plSongImage
                productDetailVC.search = true
                productDetailVC.showPlayilstSongs = true
                productDetailVC.searchIndex = indexForMM
            
            
        } else if segue.identifier == "goToChartTD" {
            let producDetailVC : AlbumViewController = segue.destination as! AlbumViewController
            if toAlbumVC == "Albums" {
                producDetailVC.canciones = TDAlbumSongs
                producDetailVC.name = artistForAlbumCH
                producDetailVC.Artistname = artistForAlbumVC
                producDetailVC.Image = imageForAlbumCH
                producDetailVC.artist = TDAlbumArtist
                producDetailVC.images = TDAlbumLinks
                type = typesAlbumVC.HomeAlbum
                
            } else if toAlbumVC == "Playlist"{
                producDetailVC.title = "Playlist"
                producDetailVC.canciones = playListSongs
                producDetailVC.name = artistForAlbumCH
                producDetailVC.Artistname = "Viro Music App"
                producDetailVC.mode = "Playlist"
                producDetailVC.Image = imageForAlbumCH
                producDetailVC.artist = plSongArtist
                producDetailVC.images = plSongImage
                producDetailVC.links = plSongLink
                type = typesAlbumVC.HomePlaylist
            } else if toAlbumVC == "Charts" {
                producDetailVC.title = "Charts"
                producDetailVC.canciones = CHSongs
                producDetailVC.name = artistForAlbumCH
                producDetailVC.Artistname = "Viro Music App"
                producDetailVC.mode = "Playlist"
                producDetailVC.Image = imageForAlbumCH
                producDetailVC.artist = CHArtist
                type = typesAlbumVC.HomeCharts
                producDetailVC.images = CHImages
                producDetailVC.artist = CHArtist
            }
            
        } else if segue.identifier == "goToNowPlayingTD" {
            if let newvc = segue.destination as? NowPlayingViewController {
                let name = playingViewSongName.text
                newvc.name = name
                newvc.Image = "http://google.es"
                newvc.imageII = playingViewImg.image
                newvc.artistName = currentSongArtist
            }
        }
        
        
    }

    //MARK: - TABLE VIEW
    
    func loadList(_ notification: Notification){
        //load data here
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return browse.count
        
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        cell.configureCell(browse[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? HomeTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard cell is HomeTableViewCell else { return }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 264
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    


}

//MARK: - COLLECTION VIEW
extension TrendyViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
          return HomeSongsT.count
        } else if collectionView.tag == 1 {
          return HomeAlbumN.count
        } else if collectionView.tag == 2{
          return charts.count
        } else {
           return plName.count
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
            cell.configureCell(HomeSongsT[(indexPath as NSIndexPath).row], image: HomeSongsL[(indexPath as NSIndexPath).row])
            return cell
        } else if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
            cell.configureCell(HomeAlbumN[(indexPath as NSIndexPath).row], image: HomeAlbumL[(indexPath as NSIndexPath).row])
            return cell
        } else if collectionView.tag == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
            cell.configureCell(charts[(indexPath as NSIndexPath).row], image: chartsImages[(indexPath as NSIndexPath).row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
            cell.configureCell(plName[(indexPath as NSIndexPath).row], image: plImage[(indexPath as NSIndexPath).row])
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            isPlaying = true
            playingViewSpinner.startAnimating()
            currentSong = ("\(HomeSongsT[(indexPath as NSIndexPath).row])")
            currentAlbum = HomeSongsAT[(indexPath as NSIndexPath).row]
            currentSongArtist = HomeSongsAT[(indexPath as NSIndexPath).row]
            let newVar = HomeSongsL[(indexPath as NSIndexPath).row].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
            self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "musicintro"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
            configurePlayingView()
            let TrackName = HomeSongsT[(indexPath as NSIndexPath).row]
            let ArtistName = HomeSongsAT[(indexPath as NSIndexPath).row]
              searchSYT().checkResult(TrackName, Parameter: TrackName+","+ArtistName, Artist: ArtistName) { () -> () in
                
            }
            
            
  
            
        } else if collectionView.tag == 1 {
            toAlbumVC = "Albums"
            TDAlbumLinks.removeAll()
            TDAlbumSongs.removeAll()
            TDAlbumArtist.removeAll()
            type = typesAlbumVC.HomeAlbum
            artistForAlbumCH = HomeAlbumN[(indexPath as NSIndexPath).row]
            imageForAlbumCH = HomeAlbumL[(indexPath as NSIndexPath).row]
            artistForAlbumVC = HomeAlbumAT[(indexPath as NSIndexPath).row]
            trendingSingles().getAlbumsSongs(HomeAlbumID[(indexPath as NSIndexPath).row]) { () -> () in
                print(TDAlbumSongs)
                self.performSegue(withIdentifier: "goToChartTD", sender: nil)
            }
        } else if collectionView.tag == 2 {
            toAlbumVC = "Charts"
            artistForAlbumCH = charts[(indexPath as NSIndexPath).row]
            imageForAlbumCH = chartsImages[(indexPath as NSIndexPath).row]
            trendingSingles().getCharts(countryCharts[(indexPath as NSIndexPath).row]) { () -> () in
                self.performSegue(withIdentifier: "goToChartTD", sender: nil)
            }
            
        } else {
            toAlbumVC = "Playlist"
            artistForAlbumCH = plName[(indexPath as NSIndexPath).row]
            imageForAlbumCH = plImage[(indexPath as NSIndexPath).row]
            trendingSingles().getSongs((indexPath as NSIndexPath).row) { () -> () in
                self.playListSongs = plSongName
                self.performSegue(withIdentifier: "goToChartTD", sender: nil)
            }
        }
        
        

        
    }
    
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}

extension TrendyViewController :  UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }
    
}

