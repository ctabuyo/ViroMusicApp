//
//  RadioViewController.swift
//  Viro
//
//  Created by Cristian Tabuyo on 12/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import MediaPlayer
import SCLAlertView

struct StretchyHeader {
    fileprivate let headerHeight: CGFloat = 210
    fileprivate let headerCut: CGFloat = 0
    
}


class RadioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - LOCALIZABLE VARIABLES
    let streamingTitle = NSLocalizedString("streaming_title", comment: "")
    
    //MARK: - VARIABLES
    var storedOffsets = [Int: CGFloat]()
    var ImgNP: String!
    var NM = [String]()
    var thumb = "hey"
    var player = [String]()
    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    
    //var refresh : UIRefreshControl?
    
    
    //MARK: - IB OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var radioLbl: UILabel!
    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var playingViewImg: UIImageView!
    @IBOutlet weak var playingViewBtn: UIButton!
    @IBOutlet weak var playingViewLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var playingViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var titleView: UIView!
    
    
    //MARK: - OVERRIDE FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(RadioViewController.loadList(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
          self.navigationController?.navigationBar.tintColor = UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0)
       UIApplication.shared.beginReceivingRemoteControlEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RadioViewController().stopAnimating),name:NSNotification.Name(rawValue: "stopAnimating"), object: nil)
        playingViewSpinner.color = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        /*refresh = UIRefreshControl()
        refresh?.tintColor = UIColor(red: 255.0/255.0, green: 102.0/255.0 , blue: 90.0/255.0, alpha: 1.0)
        refresh?.backgroundColor = UIColor.clearColor()
        refresh?.attributedTitle = NSAttributedString(string: "Drag to reload")
        refresh?.addTarget(self, action: #selector(RadioViewController.refreshStuff), forControlEvents: .ValueChanged)
        tableView.addSubview(refresh!)*/
        
        tableView.delegate = self
        tableView.dataSource = self
       
        RadioAPI().downloadRadios()
        print(Radioname)
        
        
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
    
    func refreshStuff(){
        RadioAPI().downloadRadios()
    }
    
    
    
    func loadList(_ notification: Notification){
        //load data here
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      //animateStuff()
        configurePlayingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    
    
    
    
    func configurePlayingView(){
    
        if currentSong == nil{
            playingView.isHidden = true
        }else{
            playingView.isHidden = false
            playingViewLbl.text = currentSong
            subtitleLbl.text = currentAlbum
            playingViewImg.image = currentImage
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
    
    
    func removeSpecialCharsFromString(_ text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    
    
    //MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        print(Radiocategories.count)
        return Radiocategories.count
        
    }
    
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularRadioTableViewCell", for: indexPath) as! PopularRadioTableViewCell
       
        cell.configureCell(Radiocategories[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? PopularRadioTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard cell is PopularRadioTableViewCell else { return }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 264
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func showAlertVC(_ titleData : String, messageData : String ){
        let alertVC = UIAlertController(title: titleData, message: messageData, preferredStyle: .alert)
        let alertAct = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(alertAct)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func animateStuff(){
        UIView.animate(withDuration: 0.7, delay: 0.1, usingSpringWithDamping: 3.0, initialSpringVelocity: 15, options: [], animations: {
            self.radioLbl.center.x = self.view.frame.width / 2
            
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
        
        let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut/2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView()
    }
    
    
    func setNewView(){
        
        let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut/2
        var getHeaderFrame =  CGRect(x: 0, y: -newHeight, width: view.bounds.width, height: StretchyHeader().headerHeight)
        
        if tableView.contentOffset.y < newHeight {
            
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader().headerCut/2
        }
        
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader().headerCut))
        newHeaderLayer.path = cutDirection.cgPath
        
        
        
        
    }
    
    //MARK: - IB ACTIONS
    
    @IBAction func pauseButtonAction(_ sender: AnyObject) {
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
    
    
    
    //MARK: - SEGUES
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNowPlaying" {
            if let newvc = segue.destination as? NowPlayingViewController {
                let name = playingViewLbl.text
                newvc.name = name
                newvc.Image = ImgNP
                newvc.imageII = playingViewImg.image
            }
        }
    }
    
    
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    

    
}

//MARK: - COLLECTION VIEW
extension RadioViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Radioname[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularRadioCell", for: indexPath) as! PopularRadioCell
        cell.configureCell(Radioname[collectionView.tag][(indexPath as NSIndexPath).row], image: Radioimage[collectionView.tag][(indexPath as NSIndexPath).row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pltype = PlayerType.Radio
        isPlaying = true
        playingViewSpinner.startAnimating()
        currentSong = Radioname[collectionView.tag][indexPath.row]
        currentAlbum = streamingTitle
        currentSongArtist = streamingTitle
        configurePlayingView()
        let urlImage = Radioimage[collectionView.tag][indexPath.row]
        let url = URL(string: urlImage)
        self.playingViewImg.kf.setImage(with: url, completionHandler: {
            (image, error, cacheType, imageUrl) in
            if let Image = image {
                currentImage = Image
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateInfoCenterJukebox"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
            }
            
        })
        let linkStream = Radiolink[collectionView.tag][indexPath.row]
        print(linkStream)
           UserDefaults.standard.set(true, forKey: "Radio")
           Player.sharedInstance.play(linkStream)

    }
    
    @IBAction func logOutButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "unwindSegue1", sender: self)
        jukebox.stop()
    }
}

extension RadioViewController :  UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }

}
