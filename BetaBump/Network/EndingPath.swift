//
//  EndingPath.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

enum EndingPath {
    
    case token
    case userInfo
    case artist(id: String)
    case artists(ids: [String])
    case artistTopTracks(artistId: String, country: Country)
    case search(q: String, type: SpotifyType, market: String, limit: Int, offset: Int)
    case playlist(id: String)
    case myTop(type: MyTopType)
    case tracks(ids: [String])
    
    func buildPath() -> String {
        switch self {
        case .token:
            return "token"
        case .userInfo:
            return "me"
        case .artist(let id):
            return "artist/\(id)"
        case .artists (let ids):
            return "artists&ids=\(ids.joined(separator: ","))"
        case .search(let q, let type, let market, let limit, let offset):
            let convertSpacesToProperURL = q.replacingOccurrences(of: " ", with: "%20")
        //            return "search?q=\(convertSpacesToProperURL)&type=\(type)"
            return "search?q=\(q)25&type=\(type)&market=\(market)&limit=\(limit)&offset=\(offset)"
        
        case .artistTopTracks(let id, let country):
            return "artists/\(id)/top-tracks?country=\(country)"
        case .playlist (let id):
            return "playlists/\(id)"
        case .myTop(let type):
            return "me/top/\(type)"
        case .tracks(let ids):
            return "tracks/?ids=\(ids.joined(separator: ","))"
        }
    }
    
    
}
