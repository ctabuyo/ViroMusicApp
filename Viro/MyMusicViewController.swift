//
//  MyMusicViewController.swift
//  Biro
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Jukebox
import AVFoundation
import MediaPlayer
import SCLAlertView

struct StretchyHeader3 {
    fileprivate let headerHeight: CGFloat = 210
    fileprivate let headerCut: CGFloat = 0
    
}

class MyMusicViewController: UIViewController, AVAudioPlayerDelegate {
    enum Mode {
        case shuffle
        case normal
    }

     //MARK: - LOCALIZABLE VARIABLES
     let cancelTitle = NSLocalizedString("cancel_title", comment: "")
     let takePictureTitle = NSLocalizedString("take_picture_title", comment: "")
     let libraryTitle = NSLocalizedString("library_title", comment: "")
     let errorTitleMyMusic = NSLocalizedString("search_error_title_MyMusic", comment: "")
     let errorMessageMyMusic = NSLocalizedString("search_error_message_MyMusic", comment: "")
     let infoTitle = NSLocalizedString("info_Title", comment: "")
     let infoMessage = NSLocalizedString("info_Message", comment: "")

     
    
     //MARK: - VARIABLES
    var mode = Mode.normal
    var showPlayilstSongs = false
    var playlistSongs = [String]()
    var playlistArtist = [String]()
    var playlistSongsImages = [String]()
    var index : Int!
    let closeCellHeight: CGFloat = 70
    let openCellHeight: CGFloat = 183
    var cellHeights = [CGFloat]()
    var isPlaying = false
    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    var indexPl = [String]()
    var rNumber : UInt32!
    var search = false
    var searchIndex : Int!
    
    var songs = [String]()
    var artist = [String]()
    var images = [String]()
    
    var playingIndex : Int!
    
    var normal : Bool!
    
    var dictionary = [String : (String,String,String)]()
    var shuffledDictionary : [(String, (String,String,String))]!
    var NormalDictionary : [(String, (String,String,String))]!

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var plNumber : Int!

    
    //Playing View IBOutlets
    
    @IBOutlet weak var titleLbl: UITextField!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingViewSongLbl: UILabel!
    @IBOutlet weak var playingViewArtistLbl: UILabel!
    @IBOutlet weak var playingViewBtn: UIButton!
    @IBOutlet weak var playingViewImg: UIImageView!
    @IBOutlet weak var editImageBtnOutlet: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView2: UIView!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var longPressLabel: UILabel!
    
     override func viewDidLoad() {
          UIApplication.shared.beginReceivingRemoteControlEvents()
          /*let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
           view.addGestureRecognizer(tap)*/
          
          containerView2.isHidden = true
          containerView2.alpha = 0
          tableView.isHidden = true
          myActivityIndicator.isHidden = false
          myActivityIndicator.startAnimating()
          titleLbl.delegate = self
          pltype = PlayerType.playlist
          super.viewDidLoad()
          editImageBtnOutlet.isHidden = true
          playingViewSpinner.color = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
          self.navigationController?.navigationBar.tintColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
         
          createCellHeightsArray()
          if showPlayilstSongs == true && search == false {
               titleLbl.text = dataFromParse.playlistsName[index]
          } else if showPlayilstSongs == true && search == true {
               titleLbl.text = plName[searchIndex]
          }
          
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
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
     }
    
     func doSet(notif: Notification) {
        print("This is the index: \(notif.userInfo!["Index"] as! Int!)")
       playingIndex = (notif.userInfo!["Index"] as? Int)!
     }
    
     func cancelPressed(){
          UIView.animate(withDuration: 0.3, animations: {
               self.view.backgroundColor = UIColor.white
               self.containerView2.alpha = 0
               self.tableView.alpha = 1
               self.containerView2.isHidden = false
          })
     }
    func confVW() {
        normal = true
       configurePlaying()
    }
    
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    
    func setMode() {
        mode = Mode.normal
    }
     
    func stopAnimating() {
        playingViewSpinner.stopAnimating()
    }
     
    func startAnimating() {
        playingViewSpinner.startAnimating()
    }
     
     func wantedToAdd(){
          containerView2.isHidden = false
          UIView.animate(withDuration: 0.3, animations: {
               self.view.backgroundColor = UIColor.darkGray
               self.containerView2.alpha = 1
               self.tableView.alpha = 0.1
          })
          animations()
     }

    func animations(){
          self.containerView2.center.x = -self.view.frame.width-200
          UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
               self.containerView2.center.x = self.view.frame.width / 2
          
               }, completion: nil)
    }
     
    func updateView(){
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(headerView)
        
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        let newHeight = StretchyHeader3().headerHeight - StretchyHeader3().headerCut/2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView()
    }
    
    
    
    
    func setNewView(){
        
        let newHeight = StretchyHeader3().headerHeight - StretchyHeader3().headerCut/2
        var getHeaderFrame =  CGRect(x: 0, y: -newHeight, width: view.bounds.width, height: StretchyHeader3().headerHeight)
        
        if tableView.contentOffset.y < newHeight {
            
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader3().headerCut/2
        }
        
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader3().headerCut))
        newHeaderLayer.path = cutDirection.cgPath
     }
    
        
    
    
    
    func continueP(_ notification: Notification){
        continuePlaying()
        
        
    }
     
     
    
    func continuePlaying() {
        if playingIndex < shuffledDictionary.count{
            playingIndex = playingIndex + 1
        }
     
     if playingIndex == shuffledDictionary.count {
          jukebox.stop()
     } else {
          print(playingIndex)
          if mode == Mode.shuffle {
               isPlaying = true
               currentSong = ("\(shuffledDictionary[playingIndex].0)")
               currentAlbum = shuffledDictionary[playingIndex].1.1
               currentSongArtist = shuffledDictionary[playingIndex].1.1
               let newVar = shuffledDictionary[playingIndex].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
               self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "musicintro"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                         currentImage = Image
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
               })
               configurePlaying()
                    searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                         
                    }
               
               
          } else {
               isPlaying = true
               currentSong = ("\(songs[playingIndex])")
               currentAlbum = artist[playingIndex]
               currentSongArtist = artist[playingIndex]
               let newVar = images[playingIndex].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
               self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let Image = image {
                         currentImage = Image
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
                    }
                    
               })
               configurePlaying()
               searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                         
               }
               
               
          }
  
     }
     
  }
    
    func playPlayedSong() {
        if playingIndex >= 1{
            playingIndex = playingIndex - 1
        }
        if mode == Mode.shuffle {
            isPlaying = true
            currentSong = ("\(shuffledDictionary[playingIndex].0)")
            currentAlbum = shuffledDictionary[playingIndex].1.1
            currentSongArtist = shuffledDictionary[playingIndex].1.1
            let newVar = shuffledDictionary[playingIndex].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
          self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
               (image, error, cacheType, imageUrl) in
               if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
               }
               
          })
            configurePlaying()
                searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                    
                }
            
            
        } else {
            isPlaying = true
            currentSong = ("\(songs[playingIndex])")
            currentAlbum = artist[playingIndex]
            currentSongArtist = artist[playingIndex]
            let newVar = images[playingIndex].replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
          self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
               (image, error, cacheType, imageUrl) in
               if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
               }
               
          })
            configurePlaying()
                searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                    
                }

        }
 
    }
    
     func showAlertVC(message: String){
          let alertVC = UIAlertController(title: errorTitleMyMusic, message: message, preferredStyle: .alert)
          let alertAct = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertVC.addAction(alertAct)
          present(alertVC, animated: true, completion: nil)
          playingViewSpinner.stopAnimating()
          
     }
     
    func configurePlaying() {
        isPlaying = true
        if currentSong == nil
        {
            playingView.isHidden = true
        }else{
            playingView.isHidden = false
            playingViewSongLbl.text = currentSong
            playingViewArtistLbl.text = currentAlbum
            playingViewImg.image = currentImage
        }
        
        if playingViewImg.image == nil {
            playingViewImg.image = currentImage
        }
        
        if isPlaying == true{
            
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        }else{
            
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
            
        }
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     NotificationCenter.default.removeObserver(self)

    }
     
     
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        ParseAPIManager().getParseData()
        if showPlayilstSongs == true && search == false{
            editImageBtnOutlet.isHidden = false
            titleLbl.allowsEditingTextAttributes = true
            titleLbl.isUserInteractionEnabled = true
            dataFromParse.photo[index].getDataInBackground { (imageData, errorData) -> Void in
                if errorData == nil{
                    let imageDownloaded = UIImage(data: imageData!)
                    self.backgroundImage.image = imageDownloaded
                }else{
                    print("Error while downloading the image \(self.index)")
                    
                }
            }
        }else{
            editImageBtnOutlet.isHidden = true
            titleLbl.allowsEditingTextAttributes = false
            titleLbl.isUserInteractionEnabled = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.cancelPressed),name:NSNotification.Name(rawValue: "cancelButtonPressed"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.cancelPressed),name:NSNotification.Name(rawValue: "playlistHasBeenPosted"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.songsLoaded),name:NSNotification.Name(rawValue: "mySongsLoaded"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.songDeleted),name:NSNotification.Name(rawValue: "songDeleted"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController().wantedToAdd),name:NSNotification.Name(rawValue: "wantedToAdd1"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.songDeleted),name:NSNotification.Name(rawValue: "songFromPlaylistDeleted"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.continueP),name:NSNotification.Name(rawValue: "continueP"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.playPlayedSong),name:NSNotification.Name(rawValue: "pPlayed"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.confVW),name:NSNotification.Name(rawValue: "confVW"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.setMode),name:NSNotification.Name(rawValue: "sMOD"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.doSet),name:NSNotification.Name(rawValue: "setIndex"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(MyMusicViewController.startAnimating),name:NSNotification.Name(rawValue: "startAnimating"), object: nil)
        if currentSong == nil {
           playingView.isHidden = true
          
        } else {
           playingViewSongLbl.text = currentSong
           playingViewImg.image = currentImage
           playingViewArtistLbl.text = currentAlbum
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    func createCellHeightsArray() {
        if dataFromParse != nil{
            if showPlayilstSongs == false{
                for _ in 0...dataFromParse.songs.count {
                    cellHeights.append(closeCellHeight)
                }
            }else{
                for _ in 0...playlistSongs.count {
                    cellHeights.append(closeCellHeight)
                }
            }
            
            
        }
        
    }
    
    func songsLoaded(){
     print("SONGS LOADED EXECUTED SHIT")
        if showPlayilstSongs == true {
          playlistSongs = dataFromParse.playlistsSongs[index]
          playlistArtist = dataFromParse.playlistsArtist[index]
          playlistSongsImages = dataFromParse.playlistSongsImage[index]
          songs = playlistSongs
          artist = playlistArtist
          images = playlistSongsImages

          for (i, _) in playlistSongs.enumerated() {
               dictionary[playlistSongs[i]] = ("hello",playlistArtist[i],playlistSongsImages[i])
            }

        } else {
          if songs.isEmpty == true {
            songs = dataFromParse.songs
            artist = dataFromParse.artist
            images = dataFromParse.songsImages
            for (i, _) in songs.enumerated() {
                dictionary[songs[i]] = ("hello",artist[i],images[i])
            }
          }
          
        }
     if songs.isEmpty && playlistSongs.isEmpty{
          let alertView = SCLAlertView()
          alertView.showInfo(self.infoTitle, subTitle: self.infoMessage)
     }
     
        shuffledDictionary = dictionary.shuffled()
        self.tableView.isHidden = false
     
        self.myActivityIndicator.stopAnimating()
        self.myActivityIndicator.isHidden = true
        cellHeights.removeAll()
        createCellHeightsArray()
        tableView.reloadData()
    }
    
     func songDeleted(){
          ParseAPIManager().getParseData()
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNowPlayingPL" {
            if let newvc = segue.destination as? NowPlayingViewController {
                newvc.name = currentSong
                newvc.Image = "http://google.es"
                newvc.imageII = playingViewImg.image
                newvc.artistName = currentAlbum
            }
            
        }
    }
    
    @IBAction func shuffleButton(_ sender: AnyObject) {
     if shuffledDictionary.isEmpty || shuffledDictionary.count == 0 {
         showAlertVC(message: errorMessageMyMusic)
     } else {
          mode = Mode.shuffle
          playingIndex = 0
          isPlaying = true
          playingViewSpinner.startAnimating()
          currentSong = ("\(shuffledDictionary[0].0)")
          currentAlbum = shuffledDictionary[0].1.1
          currentSongArtist = shuffledDictionary[0].1.1
          let newVar = shuffledDictionary[0].1.2.replacingOccurrences(of: "170", with: "400", options: NSString.CompareOptions.literal, range: nil)
          self.playingViewImg.kf.setImage(with: URL(string: newVar)!, placeholder: UIImage(named: "Logo"), completionHandler: {
               (image, error, cacheType, imageUrl) in
               if let Image = image {
                    currentImage = Image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
               }
               
          })
          configurePlaying()
              searchSYT().checkResult(currentSong!, Parameter: currentSong!+","+currentSongArtist!, Artist: currentSongArtist!) { () -> () in
                              
               }
     }
}

    @IBAction func editImageBtnAction(_ sender: AnyObject) {
        showPhotoMenu()
    }

    @IBAction func pauseButtonClicked(_ sender: UIButton) {
        if jukebox.state == .playing {
            jukebox.pause()
            playingViewBtn.setImage(UIImage(named: "ic_play_arrow"), for: UIControlState())
        } else {
            jukebox.play()
            playingViewBtn.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        }
    }
                    
    @IBAction func goToPlaying(_ sender: UIButton) {
        
    }
}
extension MyMusicViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataFromParse == nil{
            return 0
        }else if showPlayilstSongs == false{
           return  dataFromParse.songs.count
        }else{
           return playlistSongs.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as MySongsTableViewCell = cell else {
            return
        }
        
        if cellHeights[(indexPath as NSIndexPath).row] == closeCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMusicCell", for: indexPath) as! MySongsTableViewCell
        if showPlayilstSongs == false{
            cell.configureCell(dataFromParse.songs[(indexPath as NSIndexPath).row], album: dataFromParse.artist[(indexPath as NSIndexPath).row], image: dataFromParse.songsImages[(indexPath as NSIndexPath).row], songIndex: (indexPath as NSIndexPath).row, playlistIndex: 0, isPlaylist: showPlayilstSongs)
        } else if search == true {
            cell.configureCellDFPL(playlistSongs[playingIndex], album: playlistArtist[playingIndex], Image: playlistSongsImages[playingIndex], Index: indexPath.row)
        }else if showPlayilstSongs == true{
            cell.configureCell(playlistSongs[(indexPath as NSIndexPath).row], album: playlistArtist[(indexPath as NSIndexPath).row], image: playlistSongsImages[(indexPath as NSIndexPath).row], songIndex: (indexPath as NSIndexPath).row, playlistIndex: self.index, isPlaylist: showPlayilstSongs)
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell touched")
        let cell = tableView.cellForRow(at: indexPath) as! MySongsTableViewCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == closeCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = openCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = closeCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
        
        
    }
}

extension MyMusicViewController :  UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }
    
}

extension MyMusicViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func pickerPhoto(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
            
        }else{
            choosePhotoFromLibrary()
        }
        
    }
    
    func showPhotoMenu(){
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: takePictureTitle, style: .default) { (alert) -> Void in
            self.takePhotoWithCamera()
        }
        let chooseFromLibrary = UIAlertAction(title: libraryTitle, style: .default) { (action) -> Void in
            self.choosePhotoFromLibrary()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibrary)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromLibrary(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        backgroundImage.image = image
        ParseAPIManager().editPlaylistInfo(playlistName: titleLbl.text!, image: image, index: index)
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension MyMusicViewController : UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        ParseAPIManager().editPlaylistInfo(playlistName: titleLbl.text!, image: backgroundImage.image!, index: index)
    }
}
