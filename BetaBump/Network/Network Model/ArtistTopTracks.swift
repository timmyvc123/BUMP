//
//  ArtistTopTracks.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct ArtistTopTracks: Model {
    let tracks: [ArtistTrack]
}

struct ArtistTrack: Model {
    let id: String
    let name: String
    let previewUrl: URL?
    let album: Album
}
