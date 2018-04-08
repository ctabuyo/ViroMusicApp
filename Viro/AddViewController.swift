//
//  AddViewController.swift
//  Viro
//
//  Created by Imac RDG on 22/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Parse

class AddViewController: UIViewController {
    

    
    var songName: String!
    var artistName: String!
    var songImage: String!
    
    
    @IBOutlet weak var myText: UITextView!
    @IBOutlet weak var myMusicOutlet: UIButton!
    @IBOutlet weak var myPlaylist: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.myMusic(_:)),name:NSNotification.Name(rawValue: "musicData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.myMusic1(_:)),name:NSNotification.Name(rawValue: "musicData1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.myMusic(_:)),name:NSNotification.Name(rawValue: "musicData2"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func myMusic(_ not: Notification){
        myMusicOutlet.isHidden = false
        let arr = not.object as! NSArray
        songName = arr[0] as! String
        artistName = arr[1] as! String
        songImage = arr[2] as! String
        myText.text = String(format: NSLocalizedString("Where do you want to add the song %@ by %@ ?", comment: ""), songName, artistName)
    }
    
    func myMusic1(_ not: Notification){
        myMusicOutlet.isHidden = true
        let arr = not.object as! NSArray
        songName = arr[0] as! String
        artistName = arr[1] as! String
        songImage = arr[2] as! String
        myText.text = "Where do you want to add the song \(songName!) by \(artistName!) ?"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Add2PlaylistSegue" {
            if let newvc = segue.destination as? AddToPlaylistViewController {
                newvc.artist = artistName
                newvc.songName = songName
                newvc.imageLink = songImage
                
            }
        }
    }
    
    @IBAction func myMusicAction(_ sender: AnyObject) {
        ParseAPIManager().checkAndPost(songName, albumName: artistName, image: songImage)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "songHasBeenPosted"), object: nil)
    }
    @IBAction func playlistAction(_ sender: AnyObject) {
       //ParseAPIManager().checkPlaylist(songName, artist: artistName, index: 0)
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelButtonPressed"), object: nil)
    }
    
    @IBAction func returnSegue(_ segue:UIStoryboardSegue){
        
    }
}
