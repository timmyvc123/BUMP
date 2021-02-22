//
//  SimpleTrack.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct SimpleTrack {
    let id: String
    let artistName: String?
    let title: String
    let previewUrl: URL?
    let images: [ArtistImage]
    let albumName: String
    
    init(artistName: String?, id: String, title: String, previewURL: URL?, images: [ArtistImage], albumName: String) {
        self.artistName = artistName
        self.id = id
        self.title = title
        self.previewUrl = previewURL
        self.images = images
        self.albumName = albumName
    }
}
