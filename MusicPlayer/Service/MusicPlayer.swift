//
//  MusicService.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation
import AVFoundation

final class MusicPlayer {
    
    private var player: AVPlayer?
    
    func playMusic(musicUrlString: String) {
        if let player = self.player {
            player.play()
            return
        }
        guard let url = URL(string: musicUrlString) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func pauseMusic() {
        
        player?.pause()
    }
    
}



