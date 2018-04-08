 
//
//  ParseAPIManager.swift
//  Viro
//
//  Created by Imac RDG on 17/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import UIKit
import Parse

var dataFromParse : ParseModel!

class ParseAPIManager{
    
    //MARK: - CHECK STUFF
    
    func deleteSongs(_ isPlaylist: Bool, playlistIndex: Int, songIndex: Int){
        if isPlaylist == true{
            ParseAPIManager().deleteSongFromPlaylist(playlistIndex, songIndex: songIndex)
        }else{
            ParseAPIManager().deleteNormalSong(songIndex)
        }
    }
    
    func checkAndPost(_ songName: String, albumName: String, image: String){
        if dataFromParse.songs.contains(songName) && dataFromParse.artist.contains(albumName) {
            print("song Is Already Added BITCH")
        }else{
            ParseAPIManager().postSong(songName, albumName: albumName, image: image)
        }
        
        getParseData1()
    }
    
    func createPlaylistManager(_ name: String, image: UIImage){
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageFile = PFFile(name: "image.jpg", data: imageData!)
        ParseAPIManager().createPlaylistfromCurrentUser(name, image: imageFile!)
        
    }
    
    func checkPlaylist(_ song: String, artist: String, index: Int, imageLink: String){
        if dataFromParse.songs.contains(song) && dataFromParse.artist.contains(artist){
            if dataFromParse.playlistsSongs[index].contains(song) && dataFromParse.playlistsArtist[index].contains(artist){
                print("song Is Already Added BITCH")
            }else{
                ParseAPIManager().postSongToPlaylistWithAddedSong(song, albumName: artist, index: index, image: imageLink)
            }
        }else{
            ParseAPIManager().postSongToPlaylistWithoutAddedSong(song, albumName: artist, index: index, image: imageLink)
        }
        
    }
    
    //MARK: - GET DATA FUNCTIONS
    func getParseData(){
        let myQuery = PFQuery(className:"DATA")
        myQuery.whereKey("user", equalTo: (PFUser.current()?.username)!)

            myQuery.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                
                if let objectsDataBase = objects {
                    for objectData in objectsDataBase{
                        let finalData = ParseModel(mysongs: objectData["song"] as! [String],
                            myArtist: objectData["artist"] as! [String],
                            mySongsImages: objectData["songsImages"] as! [String],
                            myPlaylistName: objectData["playlistName"] as! [String],
                            myPlaylistSongs: objectData["playlistSongs"] as![[String]],
                            myPlaylistArtist: objectData["playlistArtist"] as![[String]],
                            myobjectID: objectData.objectId! as String,
                            myPhoto: objectData["image"] as! [PFFile],
                            myPlaylistSongsImage: objectData["playlistsSongImage"] as! [[String]],
                            isPremium: objectData["premium"] as! Bool,
                            playedSongs: objectData["SongsNumber"] as! Int)
                        dataFromParse = finalData
                    }
                    print("I GOT THE DATA BITCH")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "mySongsLoaded"), object: nil)
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        
        
        }
    }
    func getParseData1(){
        let myQuery = PFQuery(className:"DATA")
        myQuery.whereKey("user", equalTo: (PFUser.current()?.username)!)
        
        myQuery.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                
                if let objectsDataBase = objects {
                    for objectData in objectsDataBase{
                        let finalData = ParseModel(mysongs: objectData["song"] as! [String],
                                                   myArtist: objectData["artist"] as! [String],
                                                   mySongsImages: objectData["songsImages"] as! [String],
                                                   myPlaylistName: objectData["playlistName"] as! [String],
                                                   myPlaylistSongs: objectData["playlistSongs"] as![[String]],
                                                   myPlaylistArtist: objectData["playlistArtist"] as![[String]],
                                                   myobjectID: objectData.objectId! as String,
                                                   myPhoto: objectData["image"] as! [PFFile],
                                                   myPlaylistSongsImage: objectData["playlistsSongImage"] as! [[String]],
                                                   isPremium: objectData["premium"] as! Bool,
                                                   playedSongs: objectData["SongsNumber"] as! Int)
                        dataFromParse = finalData
                    }
                    print("I GOT THE DATA BITCH 1")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "mySongsLoadedTrendy"), object: nil)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
            
            
        }
    }
    func getParseData2(){
        let myQuery = PFQuery(className:"DATA")
        myQuery.whereKey("user", equalTo: (PFUser.current()?.username)!)
        
        myQuery.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                
                if let objectsDataBase = objects {
                    for objectData in objectsDataBase{
                        let finalData = ParseModel(mysongs: objectData["song"] as! [String],
                                                   myArtist: objectData["artist"] as! [String],
                                                   mySongsImages: objectData["songsImages"] as! [String],
                                                   myPlaylistName: objectData["playlistName"] as! [String],
                                                   myPlaylistSongs: objectData["playlistSongs"] as![[String]],
                                                   myPlaylistArtist: objectData["playlistArtist"] as![[String]],
                                                   myobjectID: objectData.objectId! as String,
                                                   myPhoto: objectData["image"] as! [PFFile],
                                                   myPlaylistSongsImage: objectData["playlistsSongImage"] as! [[String]],
                                                   isPremium: objectData["premium"] as! Bool,
                                                   playedSongs: objectData["SongsNumber"] as! Int)
                        dataFromParse = finalData
                    }
                    print("I GOT THE DATA BITCH 1")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PlaylistsLoaded"), object: nil)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
            
            
        }
    }
    
    
    
    
    //MARK: - POST DATA FUNCTIONS
    
    //LLAMAR NADA MAS REGISTRARTE
    func postDataFromNewUser(){
        let post = PFObject(className: "DATA")
        post["song"] = []
        post["artist"] = []
        post["songsImages"] = []
        post["playlistName"] = []
        post["playlistSongs"] = [[]]
        post["playlistArtist"] = [[]]
        post["image"] = []
        post["playlistsSongImage"] = [[]]
        post["user"] = PFUser.current()?.username
        post["SongsNumber"] = 0
        post["premium"] = false
        
        
        
        post.saveInBackground { (success, error) -> Void in
            if success{
                print("SAVED BITCH!")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "newUserCreated"), object: nil)
            }else{
                
                print("error BITCH!")
            }
            
        }
        
        
        
        
        
    }
    
    func postPremium(value:Bool){
        postInstallationPremium(value: value)
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                post["premium"] = value
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "premiumUser"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    }
    
    func postInstallationPremium(value: Bool) {
        installation.setValue(value, forKey: "Premium")
        installation.saveInBackground()

    }
    
    func postPlayedSong(value: Int){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                post["SongsNumber"] = value
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "premiumUser"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    }
    
    
    func createPlaylistfromCurrentUser(_ name: String, image: PFFile){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.playlistsName.insert(name, at: 0)
                dataFromParse.playlistsSongs.insert([], at: 0)
                dataFromParse.playlistsArtist.insert([], at: 0)
                dataFromParse.playlistSongsImage.insert([], at: 0)
                dataFromParse.photo.insert(image, at: 0)
                post["playlistName"] = dataFromParse.playlistsName
                post["playlistSongs"] = dataFromParse.playlistsSongs
                post["playlistArtist"] = dataFromParse.playlistsArtist
                post["playlistsSongImage"] = dataFromParse.playlistSongsImage
                post["image"] = dataFromParse.photo
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlaylistPosted"), object: nil)
                        
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    
    }
    
    
    func postSongToPlaylistWithAddedSong(_ songName: String, albumName: String, index: Int, image: String){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.playlistsSongs[index].insert(songName, at: 0)
                dataFromParse.playlistsArtist[index].insert(albumName, at: 0)
                dataFromParse.playlistSongsImage[index].insert(image, at: 0)
                post["playlistSongs"] = dataFromParse.playlistsSongs
                post["playlistArtist"] = dataFromParse.playlistsArtist
                post["playlistsSongImage"] = dataFromParse.playlistSongsImage
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                       
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    }
    
    func postSongToPlaylistWithoutAddedSong(_ songName: String, albumName: String, index: Int, image: String){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.songs.insert(songName, at: 0)
                dataFromParse.artist.insert(albumName, at: 0)
                dataFromParse.songsImages.insert(image, at: 0)
                dataFromParse.playlistsSongs[index].insert(songName, at: 0)
                dataFromParse.playlistsArtist[index].insert(albumName, at: 0)
                dataFromParse.playlistSongsImage[index].insert(image, at: 0)
                post["song"] = dataFromParse.songs
                post["artist"] = dataFromParse.artist
                post["songsImages"] = dataFromParse.songsImages
                post["playlistSongs"] = dataFromParse.playlistsSongs
                post["playlistArtist"] = dataFromParse.playlistsArtist
                post["playlistsSongImage"] = dataFromParse.playlistSongsImage
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                        
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    }
    
    func postSong(_ songName: String, albumName: String, image: String){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.songs.insert(songName, at: 0)
                dataFromParse.artist.insert(albumName, at: 0)
                dataFromParse.songsImages.insert(image, at: 0)
                post["song"] = dataFromParse.songs
                post["artist"] = dataFromParse.artist
                post["songsImages"] = dataFromParse.songsImages
                
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("SAVED BITCH!")
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "songPosted"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
                
            }
        }
    
    }
    
    func deletePlaylist(_ index: Int){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.playlistsName.remove(at: index)
                dataFromParse.playlistSongsImage.remove(at: index)
                dataFromParse.playlistsSongs.remove(at: index)
                dataFromParse.photo.remove(at: index)
                dataFromParse.playlistsArtist.remove(at: index)
                post["playlistName"] = dataFromParse.playlistsName
                post["playlistSongs"] = dataFromParse.playlistsSongs
                post["playlistArtist"] = dataFromParse.playlistsArtist
                post["playlistsSongImage"] = dataFromParse.playlistSongsImage
                post["image"] = dataFromParse.photo
                
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("DELETED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "playlistDeleted"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
 
    }
    
    func deleteSongFromPlaylist(_ PlaylistIndex: Int, songIndex: Int){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.playlistSongsImage[PlaylistIndex].remove(at: songIndex)
                dataFromParse.playlistsSongs[PlaylistIndex].remove(at: songIndex)
                dataFromParse.playlistsArtist[PlaylistIndex].remove(at: songIndex)
                post["playlistSongs"] = dataFromParse.playlistsSongs
                post["playlistArtist"] = dataFromParse.playlistsArtist
                post["playlistsSongImage"] = dataFromParse.playlistSongsImage
                
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("DELETED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "songFromPlaylistDeleted"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }

    }
    
    func deleteNormalSong(_ songIndex: Int){
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.songs.remove(at: songIndex)
                dataFromParse.artist.remove(at: songIndex)
                dataFromParse.songsImages.remove(at: songIndex)
                post["song"] = dataFromParse.songs
                post["artist"] = dataFromParse.artist
                post["songsImages"] = dataFromParse.songsImages
                
                post.saveInBackground { (success, error) -> Void in
                    if success{
                        print("DELETED BITCH!")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "songDeleted"), object: nil)
                    }else{
                        
                        print("error BITCH!")
                    }
                    
                }
            }
        }
    }
    
    func editPlaylistInfo(playlistName:String, image: UIImage, index: Int){
        
        let query = PFQuery(className:"DATA")
        query.getObjectInBackground(withId: (dataFromParse?.myObjectId)!) {
            (newData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!)
            } else if let post = newData {
                dataFromParse.playlistsName[index] = playlistName
                post["playlistName"] = dataFromParse.playlistsName
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let imageFile = PFFile(name: "image.jpg", data: imageData!)
                dataFromParse.photo[index] = imageFile!
                post["image"] = dataFromParse.photo
                post.saveInBackground()
            }
        }
    }
    func lostPassword(_ email: String){
        PFUser.requestPasswordResetForEmail(inBackground: email)
    }
    
    
    
}
