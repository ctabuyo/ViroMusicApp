//
//  AddToPlaylistViewController.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 25/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class AddToPlaylistViewController: UIViewController {
    
    //MARK: - VARIBALES
    var artist: String!
    var songName: String!
    var imageLink: String!
    
    //MARK: - IB OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}
extension AddToPlaylistViewController: UITableViewDelegate, UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSong2PlaylistCell", for: indexPath) as! Add2PlaylistTableViewCell
       cell.configureCell(dataFromParse.playlistsName[(indexPath as NSIndexPath).row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ParseAPIManager().checkPlaylist(songName, artist: artist, index: (indexPath as NSIndexPath).row, imageLink: imageLink)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playlistHasBeenPosted"), object: nil)
        performSegue(withIdentifier: "returningBitch", sender: self)
    }

}
