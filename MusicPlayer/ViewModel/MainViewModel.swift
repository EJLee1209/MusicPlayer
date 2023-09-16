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
    
    // 경과 시간
    var elapsedTimePublisher: AnyPublisher<String?, Never> {
        return musicPlayer.elapsedTimePublisher
    }
    // 총 시간
    var totalTimePublisher: AnyPublisher<String?, Never> {
        return musicPlayer.totalTimePublisher
    }
    
    // 재생 중 / 재생 중 아님
    var isPlaying: CurrentValueSubject<Bool, Never> = .init(false)
    
    //MARK: - Input
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
    
    
}
