//
//  Playlist.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct Playlist: Model {
    let name: String
    let images: [PlaylistImage]
    let tracks: Track
}

struct PlaylistImage: Model {
    let url: URL
}

struct Track: Model {
    let items: [Item]
}

struct Item: Model {
    let track: Album
}

struct Album: Model {
    let id: String
    let album: AlbumDetail?
    let artists: [Artist]
//    let popularity: Int
    let name: String
    let durationMs: Int?
    let previewUrl: URL?
    let images: [ArtistImage]?
    
//    enum CodingKeys: String, CodingKey {
//        case artists
////        case popularity
//        case durationMS = "duration_ms"
//        case previewURL = "preview_url"
//    }
    
}

struct AlbumDetail: Model {
    let name: String
    let images: [ArtistImage]
}

struct Artist: Model {
    let name: String
    let type: String
//    let images: [ArtistImage]?
}
