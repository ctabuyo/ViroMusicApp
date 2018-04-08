//
//  PlaylistViewController.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 24/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class PlaylistViewController: UIViewController {
    
    //Localizable strings
    let infoTitle = NSLocalizedString("info_Title", comment: "")
    let infoMessage = NSLocalizedString("info_Message", comment: "")
    
    var refresh : UIRefreshControl!
    
    @IBAction func newButtonAction(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToNew", sender: self)
    }
    
    @IBAction func addPlaylistAction(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToNew", sender: self)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NewButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.navigationBar.tintColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.songsLoaded),name:NSNotification.Name(rawValue: "PlaylistsLoaded"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.songsLoaded),name:NSNotification.Name(rawValue: "playlistDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.refreshData),name:NSNotification.Name(rawValue: "PlaylistPosted"), object: nil)
        // Do any additional setup after loading the view.
        /*refresh = UIRefreshControl()
        refresh?.tintColor = UIColor(red: 182.0/255.0, green: 234.0/255.0 , blue: 209.0/255.0, alpha: 1.0)
        refresh?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh?.addTarget(self, action: #selector(PlaylistViewController.refreshData), for: .valueChanged)
        tableView.addSubview(refresh!)*/
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self?.refreshData()
                self?.tableView.dg_stopLoading()
            })
            }, loadingView: loadingView)
        //tableView.dg_setPullToRefreshFillColor(UIColor(red: 182.0/255.0, green: 234.0/255.0 , blue: 209.0/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 235/255.0, green: 139/255.0 , blue: 132/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        
    }
    
    func refreshData(){
        ParseAPIManager().getParseData2()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaylistDetail"{
            let productDetailVC: MyMusicViewController = segue.destination as! MyMusicViewController
            if let selectedArrayIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                productDetailVC.playlistSongs = dataFromParse.playlistsSongs[selectedArrayIndex]
                productDetailVC.playlistArtist = dataFromParse.playlistsArtist[selectedArrayIndex]
                productDetailVC.playlistSongsImages = dataFromParse.playlistSongsImage[selectedArrayIndex]
                productDetailVC.showPlayilstSongs = true
                productDetailVC.search = false
                productDetailVC.index = selectedArrayIndex
                
            }
        }
    }
    
    func songsLoaded(){
        tableView.reloadData()
        self.refresh?.endRefreshing()
        if dataFromParse.playlistsName.count < 2{
            NewButtonOutlet.isHidden = false
        }else{
            NewButtonOutlet.isHidden = true
        }
    }
    
    @IBAction func returnSegue2(_ segue:UIStoryboardSegue){
    }
}
extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataFromParse == nil{
            return 0
        }else{
            return  dataFromParse.playlistsName.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistTableViewCell
        dataFromParse.photo[(indexPath as NSIndexPath).row].getDataInBackground { (imageData, errorData) -> Void in
            if errorData == nil{
                
                _ = UIImage(data: imageData!)
               //cell.backgroundImage.image = imageDownloaded
            }else{
                print("Error while downloading the image \((indexPath as NSIndexPath).row)")
                
            }
        }
        
        cell.configureCell(dataFromParse.playlistsName[(indexPath as NSIndexPath).row], number: dataFromParse.playlistsSongs[(indexPath as NSIndexPath).row].count)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PlaylistDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.contentView.clipsToBounds = true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            ParseAPIManager().deletePlaylist((indexPath as NSIndexPath).row)
            
        }
        
    }
}
