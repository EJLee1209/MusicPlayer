//
//  SongApiService.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation
import Combine

final class SongApiService: ApiServiceType {
    func fetchMusic(endPoint: String) -> AnyPublisher<Song, Error> {
        return requestGET(endPoint: endPoint, decodeType: Song.self)
    }
}

