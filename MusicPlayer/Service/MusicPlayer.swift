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
    private let elapsedTimeSubject: CurrentValueSubject<Float64, Never> = .init(0.0)
    var elapsedTimePublisher: AnyPublisher<Float64, Never> {
        return elapsedTimeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    // 총 시간 Publisher
    private let totalTimeSubject: CurrentValueSubject<Float64, Never> = .init(0.0)
    var totalTimePublisher: AnyPublisher<Float64, Never> {
        return totalTimeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    // 종료 Publisher
    private let finishedSubject: PassthroughSubject<Void, Never> = .init()
    var finishedPublisher: AnyPublisher<Void, Never> {
        return finishedSubject.eraseToAnyPublisher()
    }
    
    func setup(musicUrlString: String) {
        guard let url = URL(string: musicUrlString) else { return }
        player = AVPlayer(url: url)
        
        addPeriodicTimeObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let totalTimeSecondsFloat = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
            
            guard !totalTimeSecondsFloat.isNaN,
                  !totalTimeSecondsFloat.isInfinite else { return }
            self.totalTimeSubject.send(totalTimeSecondsFloat)
        }
    }
    
    func playMusic() {
        player?.play()
    }
    
    func pauseMusic() {
        player?.pause()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Audio finished playing")
        NotificationCenter.default.removeObserver(self)
        finishedSubject.send(())
        elapsedTimeSubject.send(0.0)
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
            
            self?.elapsedTimeSubject.send(elapsedTimeSecondsFloat)
            self?.totalTimeSubject.send(totalTimeSecondsFloat)
        }
    }
    
    func seek(to seconds: Float64) {
        self.player?.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(NSEC_PER_SEC)))
    }
}



