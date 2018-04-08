//
//  File.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 29/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Jukebox
import Parse

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeValue(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


enum PlayerType {
    case search
    case playlist
    case album
    case artist
    case Radio
    case Trendy
}

enum typesAlbumVC {
    case HomeAlbum
    case HomePlaylist
    case HomeCharts
    case SearchAlbum
    case ArtistVC
    
}

// Global Localized Strings
let buyButton = NSLocalizedString("buy_button", comment: "")

var pltype : PlayerType!
var currentSong : String?
var currentAlbum : String?
var currentImage : UIImage?
var currentPLayer :AVPlayer = AVPlayer()
var currentSongArtist : String?
var isPlaying : Bool = false
var URL12 = ""
var jukebox : Jukebox!
var player: AVPlayer!
var type : typesAlbumVC!


// Parse Variables
let installation = PFInstallation.current()

// Localized Strings
let timesExceededTitle = NSLocalizedString("times_exceeded_title", comment: "")
let timesExceeded = NSLocalizedString("times_exceeded_message", comment: "")
let proceedNoCount = NSLocalizedString("proceed_nocount", comment: "")
let DismissButton = NSLocalizedString("dismissButton", comment: "")
let BuyButton = NSLocalizedString("buy_button", comment: "")

class Player: JukeboxDelegate {
    
    static let sharedInstance = Player()
    
    func setDelegate(){
        jukebox = Jukebox(delegate: self)
        
    }
    
    func play(_ Link: String) {
        jukebox.setIT(URL: [JukeboxItem(URL: URL(string: Link)!)])
        jukebox.play()
        jukebox.setImage(image: currentImage)
        let number = dataFromParse.playedSongs + 1
        ParseAPIManager().postPlayedSong(value: number)
        
        
 
    }
    
    
    
    func audioPlayerDidFinishPlaying(player: Jukebox, successfully flag: Bool) {
        print("DidFinish")
        if pltype == PlayerType.playlist {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "continueP"), object: nil)
        } else if pltype == PlayerType.artist {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "playNN"), object: nil)
        } else if pltype == PlayerType.album {
           NotificationCenter.default.post(name: Notification.Name(rawValue: "continuePAB"), object: nil) 
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo"), object: nil)
    }
    
    
    
    
    func jukeboxStateDidChange(_ state: Jukebox) {
        if pltype == PlayerType.Radio {
            if state.state.description == "Playing" {
              NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        } else if pltype == PlayerType.search {
            if state.state.description == "Playing" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        } else if pltype == PlayerType.playlist {
            if state.state.description == "Playing" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        } else if pltype == PlayerType.artist {
            if state.state.description == "Playing" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        } else if pltype == PlayerType.album {
            if state.state.description == "Playing" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        } else if pltype == PlayerType.Trendy{
            if state.state.description == "Playing" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAnimating"), object: nil)
            }
        }
        
        if state.description == "Playing" {
            jukebox.setImage(image: currentImage)
        }
       print(state.state.description)
    }

    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
       
    }
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
      jukebox.setImage(image: currentImage)
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
      NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSongInfo2"), object: nil)
      jukebox.setImage(image: currentImage)
      
    }
}


















