//
//  PopularRadio.swift
//  Viro
//
//  Created by Cristian Tabuyo on 11/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import Foundation
import AVFoundation

class PRadioPlayer {
    
    var audioPlayer = AVAudioPlayer()
    
    class var sharedInstance: PRadioPlayer {
        struct Static {
            static var instance: PRadioPlayer?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = PRadioPlayer()
        }
        return Static.instance!
    }
    
    func playAudio(link: NSURL){
        do {
            print(link)
            print("hell")
            let soundData = NSData(contentsOfURL:link)
            audioPlayer = try AVAudioPlayer(data: soundData!)
            audioPlayer.play()
        } catch {
            print("Error getting the audio file")
        }
        
        
    }
    
    func pauseAudio() {
        audioPlayer.pause()
    }
    
    func stopAudio(){
        audioPlayer.stop()
    }
}

    
    
    
    

