//
//  Song.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import Foundation

struct Song: Codable {
    let singer: String? // 아티스트명
    let album: String? // 앨범명
    let title: String? // 곡명
    let duration: Int
    let image: String // 앨범 커버 이미지
    let file: String // mp3 파일 링크
    let lyrics: String // 시간으로 구분된 가사
    
    // 시간(key):가사(value) 딕셔너리를 리턴하는 computed property
    var lyricsDict: [Float:String] {
        do {
            let regex = try NSRegularExpression(pattern:"\\[(\\d{2}:\\d{2}:\\d{3})\\](.*?)$", options:.anchorsMatchLines)
            let nsString = lyrics as NSString

            let matches = regex.matches(in : lyrics, options:[], range:NSRange(location : 0, length : nsString.length))

            let result=matches.reduce(into:[Float:String]()) { (dict, match) in
                let timeRange=match.range(at : 1)
                let stringRange=match.range(at : 2)

                if timeRange.location != NSNotFound && stringRange.location != NSNotFound {
                    let timeString=nsString.substring(with : timeRange).trimmingCharacters(in:.whitespacesAndNewlines)
                    let subString=nsString.substring(with:stringRange).trimmingCharacters(in:.whitespacesAndNewlines)
                    
                    let times = timeString.split(separator: ":")
                    let timeSeconds = Float(times[0])! * 60 + Float(times[1])! + 0.001 * Float(times[2])!
                    
                    dict[timeSeconds]=subString
                }
            }
            
            return result
        } catch {
            print("Invalid regular expression")
            return [:]
        }
    }
    
}
