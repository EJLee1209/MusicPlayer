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
    
    init(apiService: ApiServiceType) {
        self.apiService = apiService
        
        
    }
    
    
    //MARK: - output
    private let songSubject: PassthroughSubject<Song, Never> = .init()
    // 곡 명
    var songTitle: AnyPublisher<String?, Never> {
        return songSubject.map { $0.title }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 아티스트명
    var songArtist: AnyPublisher<String?, Never> {
        return songSubject.map { $0.singer }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 앨범명
    var songAlbum: AnyPublisher<String?, Never> {
        return songSubject.map { $0.album }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    // 이미지 url
    var songImageUrl: AnyPublisher<URL, Never> {
        return songSubject.compactMap { URL(string: $0.image) }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
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
            }.store(in: &cancellables)
    }
    
    func togglePlayState() {
        isPlaying.send(!isPlaying.value)
    }
    
}
