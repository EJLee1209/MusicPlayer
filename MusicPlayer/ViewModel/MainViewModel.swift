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
    let apiService: ApiServiceType
    
    init(apiService: ApiServiceType) {
        self.apiService = apiService
        
        self.apiService.fetchMusic(endPoint: Constants.songEndPoint)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] song in
                self?.songSubject.send(song)
            }.store(in: &cancellables)

    }
    
    
    //MARK: - output
    private let songSubject: PassthroughSubject<Song, Never> = .init()
    var songPublisher: AnyPublisher<Song, Never> {
        return songSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    
    
}
