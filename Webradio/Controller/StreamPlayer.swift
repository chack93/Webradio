//
//  StreamPlayer.swift
//  Webradio
//
//  Created by Christian Hackl on 01/01/2017.
//  Copyright © 2017 Christian Hackl. All rights reserved.
//

import Foundation
import AVFoundation

class StreamPlayer: NSObject {
    // MARK: - Properties
    var station: Station? {
        didSet {
            guard let streams = self.station?.streams else {
                Debug.log(level: .Debug, file: self.className, msg: "Set station is empty")
                return
            }
            var stream: URL?
            for item in streams {
                if item.isDefault {
                    stream = URL.init(string: item.stream)
                    break
                }
            }
            if stream == nil {
                Debug.log(level: .Error, file: self.className, msg: "No stream avaiable")
                return
            }
            self.playerItem = AVPlayerItem.init(url: stream!)
        }
    }
    private var playerItem: AVPlayerItem?
    private var player = AVPlayer()
    var volumeLevel: Float = 1.0 {
        didSet {
            self.player.volume = volumeLevel
        }
    }
    dynamic var isPlaying: Bool = false
    
    // MARK: - Play functions
    func play() {
        guard let playerItem = self.playerItem else {
            Debug.log(level: .Error, file: self.className, msg: "Player item is empty")
            return
        }
        if self.player.currentItem == playerItem {
            return
        }
        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
        
        let now = Date.init()
        let maxTime = now.addingTimeInterval(2)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {(timer) -> Void in
            if self.player.timeControlStatus == .playing {
                self.isPlaying = true
                timer.invalidate()
            }
            if timer.fireDate > maxTime {
                self.player.replaceCurrentItem(with: nil)
                self.player.pause()
                self.isPlaying = false
                timer.invalidate()
            }
        })
    }
    
    func pause() {
        self.player.pause()
        self.isPlaying = false
    }
}
