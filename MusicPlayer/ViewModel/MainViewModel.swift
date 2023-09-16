//
//  MainViewModel.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation
import Combine

final class MainViewModel {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private let apiService: ApiServiceType
    private let musicPlayer: MusicPlayer
    
    init(apiService: ApiServiceType, musicPlayer: MusicPlayer) {
        self.apiService = apiService
        self.musicPlayer = musicPlayer
        
        self.isPlaying
            .dropFirst()
            .sink { [weak self] state in
                self?.playOrPauseMusic(isPlaying: state)
            }.store(in: &cancellables)
        
        self.musicPlayer.finishedPublisher
            .sink { [weak self] _ in
                self?.musicPlayer.setup(musicUrlString: self?.songSubject.value?.file ?? "")
                self?.isPlaying.send(false)
            }.store(in: &cancellables)
        
        // SeekBar를 조작했을 때, 재생 시작 시점이 변경되는 것을 구독
        self.progress
            .sink { [weak self] progress in
                self?.musicPlayer.seek(to: Float64(progress))
            }.store(in: &cancellables)
    }
    
    
    //MARK: - output
    private let songSubject: CurrentValueSubject<Song?, Never> = .init(nil)
    // 곡 명
    var songTitle: AnyPublisher<String?, Never> {
        return songSubject.map { $0?.title }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 아티스트명
    var songArtist: AnyPublisher<String?, Never> {
        return songSubject.map { $0?.singer }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 앨범명
    var songAlbum: AnyPublisher<String?, Never> {
        return songSubject.map { $0?.album }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 이미지 url
    var songImageUrl: AnyPublisher<URL, Never> {
        return songSubject.compactMap { URL(string: $0?.image ?? "") }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    // 경과 시간 ("00:00")
    var formatedElapsedTimePublisher: AnyPublisher<String?, Never> {
        return musicPlayer.elapsedTimePublisher.map { [weak self] time in
            self?.formatTime(time: time)
        }.eraseToAnyPublisher()
    }
    // 총 시간 ("00:00")
    var formatedTotalTimePublisher: AnyPublisher<String?, Never> {
        return musicPlayer.totalTimePublisher.map { [weak self] time in
            self?.formatTime(time: time)
        }.eraseToAnyPublisher()
    }
    
    var elapsedTimePublisher: AnyPublisher<Float, Never> {
        return musicPlayer.elapsedTimePublisher.map { Float($0) }.eraseToAnyPublisher()
    }
    
    var totalTimePublisher: AnyPublisher<Float, Never> {
        return musicPlayer.totalTimePublisher.map { Float($0) }.eraseToAnyPublisher()
    }
    
    var progressPublisher: AnyPublisher<String?, Never> {
        return progress.map { [weak self] time in
            self?.formatTime(time: time)
        }.eraseToAnyPublisher()
    }
    
    // 재생 중 / 재생 중 아님
    var isPlaying: CurrentValueSubject<Bool, Never> = .init(false)
    
    //MARK: - Input
    let progress: PassthroughSubject<CGFloat, Never> = .init()
    
    func requestMusic() {
        self.apiService.fetchMusic(endPoint: Constants.songEndPoint)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] song in
                self?.songSubject.send(song)
                self?.musicPlayer.setup(musicUrlString: song.file)
            }.store(in: &cancellables)
    }
    
    func togglePlayState() {
        isPlaying.send(!isPlaying.value)
    }
    
    
    //MARK: - Helpers
    private func playOrPauseMusic(isPlaying: Bool) {
        if isPlaying {
            self.musicPlayer.playMusic()
        } else {
            self.musicPlayer.pauseMusic()
        }
    }
    
    private func formatTime(time: Float64) -> String {
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
