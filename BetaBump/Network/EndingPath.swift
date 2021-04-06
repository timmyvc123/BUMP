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
    case createPlaylist(id: String)
//    case getReccommendations(limit: Int, market: String?, minAttributes: [(TuneableTrackAttribute, Float)]?, maxAttributes: [(TuneableTrackAttribute, Float)]?, targetAttributes: [(TuneableTrackAttribute, Float)]?, seedArtists: [String]?, seedGenres: [String]?, seedTracks: [String]?)
    
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
            return "search?q=\(q)20&type=\(type)&market=\(market)&limit=\(limit)&offset=\(offset)"
        // corerctly get year and genre
//            "search?q=\(q)20year:2020%20genre:%22southern%20hip%20hop%22&type=\(type)&market=\(market)&limit=\(limit)&offset=\(offset)"
        case .artistTopTracks(let id, let country):
            return "artists/\(id)/top-tracks?country=\(country)"
        case .playlist (let id):
            return "playlists/\(id)"
        case .myTop(let type):
            return "me/top/\(type)"
        case .tracks(let ids):
            return "tracks/?ids=\(ids.joined(separator: ","))"
        case .createPlaylist(let id):
            return "users/\(id)/playlists"
//        case .getReccommendations(let limit, let market, let minAttributes, let maxAttributes, let targetAttributes, let seedArtists, let seedGenres, let seedTracks):
//            var parameters: [String: Any] = ["limit" : limit]
//
//            let max = checkOptionalTuneableTrackAttributeTupleParamAddition(prefix: "max", attributes: maxAttributes, parameters: &parameters)
//            let min  = checkOptionalTuneableTrackAttributeTupleParamAddition(prefix: "min", attributes: minAttributes, parameters: &parameters)
//            let target = checkOptionalTuneableTrackAttributeTupleParamAddition(prefix: "target", attributes: targetAttributes, parameters: &parameters)
//            print("MAX: \(max) MIN: \(min) Target: \(target)")
//
//            let seedArtists = checkOptionalArrayParamAddition(paramName: "seed_artists", param: seedArtists, parameters: &parameters)
//            let seedGenres = checkOptionalArrayParamAddition(paramName: "seed_genres", param: seedGenres, parameters: &parameters)
//            let seedTracks = checkOptionalArrayParamAddition(paramName: "seed_tracks", param: seedTracks, parameters: &parameters)
//
//            return "recommendations?limit=\(limit)&market=\(market)&\(max)&\(min)&\(seedArtists)&\(seedGenres)&\(seedTracks)&\(target)"
//        recommendations?limit=2&market=US&max_energy=0.8&max_popularity=70&min_energy=0.4&min_popularity=30&seed_tracks=6iKFUkq6GmaW4UQGED1tSd&target_energy=0.6&target_popularity=50
            
        }
    }
    
    
    private func checkOptionalTuneableTrackAttributeTupleParamAddition(prefix: String,
                                                                             attributes: [(TuneableTrackAttribute, Float)]?,
                                                                             parameters: inout [String: Any]) {
        
        guard let attributes = attributes else {
            return
        }
        
        for (attribute, value) in attributes {
            parameters["\(prefix)_\(attribute.rawValue)"] = value
        }
    }
    
    private func checkOptionalArrayParamAddition(paramName: String,
                                                       param: [String]?,
                                                       parameters: inout [String: Any]) {
        if let param = param {
            parameters[paramName] = param.joined(separator: ",")
        }
    }
    
    
}
