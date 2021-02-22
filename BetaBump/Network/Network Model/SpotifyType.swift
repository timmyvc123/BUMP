//
//  SpotifyType.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

enum SpotifyType: String {
    case album = "ablum"
    case artist = "artist"
    case playlist = "playlist"
    case track = "track"
    case show = "show"
    case episode = "episode"

}

enum MyTopType: String {
    case tracks = "tracks"
    case artists = "artists"

//    func getType() -> String {
//        switch self {
//        case .tracks:
//            return "tracks"
//        case .artists:
//            return "artists"
//        }
//    }
}


enum Country: String {
    case US = "US"
    case UK = "UK"
}



