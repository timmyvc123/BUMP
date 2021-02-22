//
//  UserTopTracks.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct UserTopArtists: Model {
    let items: [ArtistItem]
}

struct ArtistItem: Model {
    let id: String
    let name: String
    let images: [ArtistImage]
}

struct ArtistImage: Model {
    let height: Int
    let url: URL
}
