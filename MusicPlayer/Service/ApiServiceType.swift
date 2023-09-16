//
//  ApiServiceType.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation
import Combine

protocol ApiServiceType {
    func fetchMusic(endPoint: String) -> AnyPublisher<Song, Error>
}

extension ApiServiceType {
    func requestGET<T: Decodable>(endPoint: String, decodeType: T.Type) -> AnyPublisher<T, Error> {
        let url = URL(string: endPoint)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
