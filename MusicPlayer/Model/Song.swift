//
//  Song.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation

struct Song: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: String
}
