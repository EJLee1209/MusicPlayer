//
//  Song.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation

struct Song: Codable {
    let singer: String // 아티스트명
    let album: String // 앨범명
    let title: String // 곡명
    let duration: Int
    let image: String // 앨범 커버 이미지
    let file: String // mp3 파일 링크
    let lyrics: String // 시간으로 구분된 가사
}
