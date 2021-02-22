//
//  SearchTracks.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct SearchTracks: Model {
    let tracks: Tracks
}

struct Tracks: Model {
    let items: [ArtistTrack]
}

