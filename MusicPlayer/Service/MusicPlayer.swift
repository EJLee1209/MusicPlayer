//
//  MusicService.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation
import AVFoundation
import Combine

final class MusicPlayer {
    
    private var player: AVPlayer?
    
    // 경과 시간 Publisher
    private let elapsedTimeSubject: CurrentValueSubject<String?, Never> = .init("00:00")
    var elapsedTimePublisher: AnyPublisher<String?, Never> {
        return elapsedTimeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    // 총 시간 Publisher
    private let totalTimeSubject: CurrentValueSubject<String?, Never> = .init("00:00")
    var totalTimePublisher: AnyPublisher<String?, Never> {
        return totalTimeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    func setup(musicUrlString: String) {
        guard let url = URL(string: musicUrlString) else { return }
        player = AVPlayer(url: url)
        
        addPeriodicTimeObserver()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let totalTimeSecondsFloat = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
            
            guard !totalTimeSecondsFloat.isNaN,
                  !totalTimeSecondsFloat.isInfinite else { return }
            self.totalTimeSubject.send(self.formatTime(time: totalTimeSecondsFloat))
        }
    }
    
    func playMusic() {
        player?.play()
    }
    
    func pauseMusic() {
        player?.pause()
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
        
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] elapsedTime in
            let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedTime)
            let totalTimeSecondsFloat = CMTimeGetSeconds(self?.player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
            guard !elapsedTimeSecondsFloat.isNaN,
                  !elapsedTimeSecondsFloat.isInfinite,
                  !totalTimeSecondsFloat.isNaN,
                  !totalTimeSecondsFloat.isInfinite else { return }
            
            print(elapsedTimeSecondsFloat)
            self?.elapsedTimeSubject.send(self?.formatTime(time: elapsedTimeSecondsFloat))
            self?.totalTimeSubject.send(self?.formatTime(time: totalTimeSecondsFloat))
        }
    }
    
    private func formatTime(time: Float64) -> String {
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}



