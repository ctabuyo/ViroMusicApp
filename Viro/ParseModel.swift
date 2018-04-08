//
//  ParseModel.swift
//  Viro
//
//  Created by Imac RDG on 17/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import Parse

class ParseModel: NSObject {
    
    //MARK: - VARIABLES
    
    var songs = [String]()
    var artist = [String]()
    var songsImages = [String]()
    var playlistsName = [String]()
    var playlistsSongs = [[String]]()
    var playlistsArtist = [[String]]()
    var playlistSongsImage = [[String]]()
    var myObjectId : String
    var isPremium : Bool
    var playedSongs : Int
    var photo = [PFFile]()
    //MARK: - INIT
    init (mysongs:[String], myArtist: [String], mySongsImages: [String], myPlaylistName: [String], myPlaylistSongs: [[String]], myPlaylistArtist: [[String]], myobjectID: String, myPhoto: [PFFile], myPlaylistSongsImage: [[String]], isPremium: Bool, playedSongs: Int){
        self.songs = mysongs
        self.artist = myArtist
        self.songsImages = mySongsImages
        self.playlistsName = myPlaylistName
        self.myObjectId = myobjectID
        self.playlistsSongs = myPlaylistSongs
        self.playlistsArtist = myPlaylistArtist
        self.photo = myPhoto
        self.playlistSongsImage = myPlaylistSongsImage
        self.isPremium = isPremium
        self.playedSongs = playedSongs
        super.init()
        
    }
    
    
    
    
}
