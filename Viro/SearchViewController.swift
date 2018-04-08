//
//  SearchViewController.swift
//  Biro
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import MediaPlayer
import Jukebox
import SCLAlertView
import Parse

class SearchViewController: UIViewController, UISearchBarDelegate{
    
    //MARK: - LOCALIZABLE VARIABLES
    let errorTitle = NSLocalizedString("search_error_title", comment: "")
    let errorMessage = NSLocalizedString("search_error_message", comment: "")
    let searchBarTitle = NSLocalizedString("search_Bar_Title", comment: "")
    let songsTitles = NSLocalizedString("songs_title", comment: "")
    let albumsTitles = NSLocalizedString("albums_title", comment: "")
    let artistTitles = NSLocalizedString("artist_title", comment: "")
    let videoTooLongTitle = NSLocalizedString("videoLong_title", comment: "")
    let videoTooLongTitleMessage = NSLocalizedString("videoLong_error", comment: "")
    
    // MAvar Properties
    var firstErrorSkip = true
    var firstInstanceSkip = true
    
    var URI = [String]()
    var imageString: String!
    var sections1 = [String]()
    //MARK: - VC Variables
    let searchController = UISearchController(searchResultsController: nil)
    var shouldShowSearchResults = false
    var nameForAlbum: String!
    var aNameForAlbum: String!
    var albumImage : String!
    var ArtistName : String!
    var ArtistImage : String!
    
    var matches = false
    
    
    
    //MARK: - IB OUTLETS
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingviewImg: UIImageView!
    @IBOutlet weak var playingViewTxt: UILabel!
    @IBOutlet weak var playingViewBtn: UIButton!
    @IBOutlet weak var playingViewsubtitle: UILabel!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    

    @IBOutlet weak var playingViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        pltype = PlayerType.search
        
          self.navigationController?.navigationBar.tintColor = UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0)
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        tableView.allowsSelection = false
        searchButtonOutlet.isHidden = false
        playingViewActivityIndicator.isHidden = true
        playingViewActivityIndicator.stopAnimating()
        
        containerView.isHidden = true
        containerView.alpha = 0
        playingviewImg.image = currentImage
        
        playingViewSpinner.color = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController().wantedToAdd),name:NSNotification.Name(rawValue: "wantedToAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.loadList(_:)),name:NSNotification.Name(rawValue: "loadSC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.loadMusic(_:)),name:NSNotification.Name(rawValue: "loadMS"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.cancelPressed),name:NSNotification.Name(rawValue: "songHasBeenPosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.cancelPressed),name:NSNotification.Name(rawValue: "cancelButtonPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.cancelPressed),name:NSNotification.Name(rawValue: "playlistHasBeenPosted"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController().showAlertVC),name:NSNotification.Name(rawValue: "alertVCSearch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController().showAlertVC3),name:NSNotification.Name(rawValue: "alertVCTooLong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController().stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        configureSearchController()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if currentSong == nil {
            playingView.isHidden = true
            
        } else {
            playingView.isHidden = false
            playingViewTxt.text = currentSong
            playingviewImg.image = currentImage
            playingViewsubtitle.text = currentAlbum
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if TNames.isEmpty{
        }else{
            for ID in Array(Set(ArtistID)) {
                iTunes().getAlbums2(Int(ID)) { () -> () in
                    self.tableView.reloadData()
                    self.tableView.reloadData()
                }
            }
        }
        
        super.viewWillAppear(animated)
        ParseAPIManager().getParseData1()
        if dataFromParse == nil{
            // ParseAPIManager().newUser()
        }
        
        
        
        configurePlayingView()
    }
    
    
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    //MARK: - NSNotification Functions
    
    func wantedToAdd(){
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.darkGray
            self.containerView.alpha = 1
            self.tableView.alpha = 0.1
        })
        animations()
    }
    
    func loadList(_ notification: Notification){
        //load data here
        self.tableView.reloadData()
    }
    
    func loadMusic(_ notification: Notification){
        //load data here
        
    }
        
    func cancelPressed(){
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.white
            self.containerView.alpha = 0
            self.tableView.alpha = 1
            self.containerView.isHidden = false
        })
        
    }
    
    func showAlertVC(){
        let alertView = SCLAlertView()
        alertView.showError(errorTitle, subTitle: errorMessage)
        playingViewSpinner.stopAnimating()
        
    }
    
    func showAlertVC3(){
        let alertView = SCLAlertView()
        alertView.showError(videoTooLongTitle, subTitle: videoTooLongTitleMessage)
        playingViewSpinner.stopAnimating()
        
    }
    
    
    
    
    func stopAnimating() {
        playingViewSpinner.stopAnimating()
    }
    
    func configureSearchController(){

        searchController.searchBar.delegate = self
      
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.init(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0)
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.isTranslucent = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = searchBarTitle
    }
    
    
    
    // MARK: - MY FUNCTIONS
    func configurePlayingView(){
        
        if currentSong == nil
        {
            playingView.isHidden = true
        }else{
            playingView.isHidden = false
            playingViewTxt.text = currentSong
            playingViewsubtitle.text = currentAlbum
        }
        
        if isPlaying==true{
            
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        }else{
            
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
            
        }
    }
    
    func animations(){
        self.containerView.center.x = -self.view.frame.width-200
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.containerView.center.x = self.view.frame.width / 2
            
            }, completion: nil)
    }
    
    
    @IBAction func searchButtonAction(_ sender: AnyObject) {
        self.searchController.searchBar.becomeFirstResponder()
    }
    //MARK: - SEARCH BAR FUNCTIONS
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        searchButtonOutlet.isHidden = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
        if sections1.isEmpty{
            searchButtonOutlet.isHidden = false
        }else{
            searchButtonOutlet.isHidden = true
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
            if shouldShowSearchResults == true{
                TNames.removeAll()
                ANames.removeAll()
                TLinks.removeAll()
                ALinks.removeAll()
                ATNames.removeAll()
                playingViewActivityIndicator.isHidden = false
                playingViewActivityIndicator.startAnimating()
                Parameter = searchController.searchBar.text!
                iTunes().getTracks(Parameter) { () -> () in
                    self.sections1 = [self.songsTitles, self.artistTitles, self.albumsTitles]
                        self.searchButtonOutlet.isHidden = true
                    
                    //this will be called after download is done
                    UIView.animate(withDuration: 0.1, animations: {
                        self.tableView.alpha = 1
                        self.playingViewActivityIndicator.isHidden = true
                        self.playingViewActivityIndicator.stopAnimating()
                    })
                    if TNames.isEmpty{
                        self.showAlertVC()
                    }else{
                    for ID in Array(Set(ArtistID)) {
                        iTunes().getAlbums2(Int(ID)) { () -> () in
                            self.tableView.reloadData()
                            self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                
            }
            UIView.animate(withDuration: 0.1, animations: {
                self.tableView.alpha = 0.1
            })
            searchController.searchBar.resignFirstResponder()
    }
    
    
    
    //MARK: - SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToNowPlaying2" {
            if let newvc = segue.destination as? NowPlayingViewController {
                let name = playingViewTxt.text
                newvc.name = name
                newvc.Image = imageString
                newvc.imageII = playingviewImg.image
                newvc.artistName = currentSongArtist
            }
        } else if segue.identifier == "goToAlbum" {
            if let newvc = segue.destination as? AlbumViewController {
                type = typesAlbumVC.SearchAlbum
                newvc.canciones = iTunesAPI().removeDuplicates(APTNames)
                newvc.images = APTImages
                newvc.name = nameForAlbum
                newvc.Artistname = aNameForAlbum
                newvc.Image = albumImage
                newvc.artist = APTArtist
                
            }
        } else if segue.identifier == "goToArtist" {
           if let newvc = segue.destination as? ArtistViewController {
                newvc.image = ArtistImage
                newvc.albums = iTunesAPI().removeDuplicates(AlbumsArtist)
                newvc.songs =  iTunesAPI().removeDuplicates(TracksArtist)
                newvc.name = ArtistName
            }
        }/*else if segue.identifier == "SegueToCell" {
            let productDetailVC: AddViewController = segue.destinationViewController as! AddViewController
            if let selectedArrayIndex = tableView.indexPathForSelectedRow?.row {
                productDetailVC.songName = TNames[selectedArrayIndex]
                productDetailVC.artistName = ATNames[selectedArrayIndex]
            }
        }*/
    }
    
    
    
    //MARK: - IB ACTIONS
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
    
    
}



extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    
    //TABLE VIEW EXTENSION
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections1.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Search2TableViewCell
        
    
        cell.configureCell(sections1[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        guard let tableViewCell = cell as? Search2TableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard cell is Search2TableViewCell else { return }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 264
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            return TNames.count
        } else if collectionView.tag == 1 {
            return iTunesAPI().removeDuplicates(ATNames).count
        } else {
            return ANames.count
        }

     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchRadioCell", for: indexPath) as! SearchCollectionViewCell
        if collectionView.tag == 0 {
            cell.configureCell(TNames[(indexPath as NSIndexPath).row], image: TLinks[(indexPath as NSIndexPath).row], index: collectionView.tag, artist: ATNames[(indexPath as NSIndexPath).row])
        } else if collectionView.tag == 1 {
            cell.configureCell(iTunesAPI().removeDuplicates(ATNames)[(indexPath as NSIndexPath).row], image: ALinks[(indexPath as NSIndexPath).row], index: collectionView.tag, artist: "")
        } else {
            cell.configureCell(ANames[(indexPath as NSIndexPath).row], image: AlbumLinks[(indexPath as NSIndexPath).row], index: collectionView.tag, artist: "")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(collectionView.tag)
        if collectionView.tag == 0 {
            isPlaying = true
            playingViewSpinner.startAnimating()
            currentSong = ("\(TNames[(indexPath as NSIndexPath).row])")
            currentAlbum = ATNames[(indexPath as NSIndexPath).row]
            currentSongArtist = ATNames[(indexPath as NSIndexPath).row]
            self.playingviewImg.kf.setImage(with: URL(string: TLinks[(indexPath as NSIndexPath).row])!, placeholder: UIImage(named: "Logo"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let Image = image {
                    currentImage = Image
                    self.imageString = TLinks[(indexPath as NSIndexPath).row]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                }
                
            })
            configurePlayingView()
            let TrackName = TNames[(indexPath as NSIndexPath).row]
            let ArtistName = ATNames[(indexPath as NSIndexPath).row]
            indexPathf = (indexPath as NSIndexPath).row
            print(GenreSong[indexPath.row])
            if GenreSong[indexPath.row] == "Classical" {
                searchSYT().checkResult(TrackName, Parameter: TrackName, Artist: ArtistName) { () -> () in
                    
                }
            } else {
                searchSYT().checkResult(TrackName, Parameter: TrackName+","+ArtistName, Artist: ArtistName) { () -> () in
                    
                }
            }
            
            
            
            
            
        
        
        
        } else if collectionView.tag == 1{
            var name = iTunesAPI().removeDuplicates(ATNames)[(indexPath as NSIndexPath).row]
            ArtistName = name
            ArtistImage = ALinks[(indexPath as NSIndexPath).row]
            print(ArtistID[(indexPath as NSIndexPath).row])
            artistData().getAlbums(ArtistID[(indexPath as NSIndexPath).row]){ () -> () in
                if let dotRange = name.range(of: "feat")    {
                   name.removeSubrange(dotRange.lowerBound..<name.endIndex)
                } else if let dotRange2 = name.range(of: "ft") {
                    name.removeSubrange(dotRange2.lowerBound..<name.endIndex)
                } else if let dotRange3 = name.range(of: "&") {
                    name.removeSubrange(dotRange3.lowerBound..<name.endIndex)
                }
                artistData().getTracks(name){ () -> () in
                    self.performSegue(withIdentifier: "goToArtist", sender: nil)
                   
                }
            }
            
           
        } else if collectionView.tag == 2 {
            iTunes().getAlbums(colId[(indexPath as NSIndexPath).row]) { () -> () in
                self.nameForAlbum = ANames[(indexPath as NSIndexPath).row]
                self.aNameForAlbum = ATNames[(indexPath as NSIndexPath).row]
                self.albumImage = AlbumLinks[(indexPath as NSIndexPath).row]
                self.performSegue(withIdentifier: "goToAlbum", sender: nil)
            }

        }
    }

}



